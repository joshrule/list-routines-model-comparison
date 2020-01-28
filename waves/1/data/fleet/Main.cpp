enum class CustomOp {
	op_STREQ,op_EMPTYSTRING,op_EMPTY,op_A,op_CDR,op_CAR,op_CONS,op_NUM,
	op_REPEAT,op_INCR
};

// Define our types. 
#define NT_TYPES bool,std::string
#define NT_NAMES nt_bool,nt_string

// Includes critical files. Also defines some variables (mcts_steps, explore, etc.) that get processed from argv 
#include "Fleet.h" 

using S = std::string; // just for convenience

S alphabet = "0123456789,"; // the alphabet we use (possibly specified on command line)

const double strgamma = 0.99; // penalty on string length

// Define a grammar
class MyGrammar : public Grammar { 
public:
	MyGrammar() : Grammar() {
		add( Rule(nt_string, BuiltinOp::op_X,            "x",            {},                               10.0) );		
		add( Rule(nt_string, BuiltinOp::op_SAFE_RECURSE, "F(%s)",        {nt_string},                      2.0) );		

		for(size_t i=0;i<alphabet.length();i++)
			add( Rule(nt_string, CustomOp::op_A,    Q(alphabet.substr(i,1)),   {},                         10.0/alphabet.length(), i) );

		add( Rule(nt_string, CustomOp::op_EMPTYSTRING,  "\u00D8",           {},                               1.0) );
		
		
		add( Rule(nt_string, CustomOp::op_CONS,         "cons(%s,%s)",  {nt_string,nt_string},            1.0) );
		add( Rule(nt_string, CustomOp::op_CAR,          "head(%s)",      {nt_string},                      1.0) );
		add( Rule(nt_string, CustomOp::op_CDR,          "tail(%s)",      {nt_string},                      1.0) );
		
		add( Rule(nt_string, BuiltinOp::op_IF,          "if(%s,%s,%s)", {nt_bool, nt_string, nt_string},  1.0) );
		
		add( Rule(nt_bool,   CustomOp::op_EMPTY,        "empty(%s)",    {nt_string},                      1.0) );
		add( Rule(nt_bool,   CustomOp::op_STREQ,        "(%s==%s)",     {nt_string,nt_string},            1.0) );
	}
};


/* Define a class for handling my specific hypotheses and data. Everything is defaulty a PCFG prior and 
// * regeneration proposals, but I have to define a likelihood */
class MyHypothesis : public LOTHypothesis<MyHypothesis,Node,nt_string, S, S> {
public:

	using Super = LOTHypothesis<MyHypothesis,Node,nt_string, S, S>;
	static const size_t MAX_LENGTH = 64; // longest strings cons will handle
	
	// I must implement all of these constructors
	MyHypothesis()                     : Super() {}
	MyHypothesis(Grammar* g)           : Super(g) {}
	MyHypothesis(Grammar* g, Node v)   : Super(g,v) {}
	

	double compute_single_likelihood(const t_datum& x) {
		auto out = callOne(x.input, "<err>"); // NOTE NOT STOCHASTIC

//		CERR string() TAB "OUT=" << out TAB "D="<<x.input TAB x.output ENDL;
		if(is_prefix(out, x.output)) {
			return log((1.0-strgamma)/alphabet.length()) * (x.output.length() - out.length());
		}
		else {
			return -infinity;
		}
	}
	
	abort_t dispatch_rule(Instruction i, VirtualMachinePool<S,S>* pool, VirtualMachineState<S,S>& vms, Dispatchable<S,S>* loader ) {
		switch(i.getCustom()) {
			CASE_FUNC0(CustomOp::op_A,           S,          [i](){ return alphabet.substr(i.arg, 1);} )
			CASE_FUNC0(CustomOp::op_EMPTYSTRING, S,          [](){ return S("");} )
			CASE_FUNC1(CustomOp::op_EMPTY,       bool,  S,   [](const S& s){ return s.size()==0;} )
			CASE_FUNC2(CustomOp::op_STREQ,       bool,  S,S, [](const S& a, const S& b){return a==b;} )
			CASE_FUNC1(CustomOp::op_CDR,         S, S,       [](const S& s){ return (s.empty() ? S("") : s.substr(1,S::npos)); } )		
			CASE_FUNC1(CustomOp::op_CAR,         S, S,       [](const S& s){ return (s.empty() ? S("") : S(1,s.at(0))); } )		
			
			CASE_FUNC2e(CustomOp::op_CONS,       S, S,S,
								[](const S& x, const S& y){ S a = x; a.append(y); return a; },
								[](const S& x, const S& y){ return (x.length()+y.length()<MAX_LENGTH ? abort_t::NO_ABORT : abort_t::SIZE_EXCEPTION ); }
								)
								
			default: assert(0 && " *** You ended up with an invalid argument"); // should never get here
		}
		return abort_t::NO_ABORT;
	}
	
//	void print(std::string prefix="") {
//		auto out = call("12345", "<err>", this, 256, 256);
//		Super::print(out.string() + "\t");
//	}
};


MyHypothesis::t_data mydata;
TopN<MyHypothesis> top;


////////////////////////////////////////////////////////////////////////////////////////////

S decomma(S& s) {
	// conver 1,2,3 to 123 and force everything into the ascii range 48-125
	auto parts = split(s, ',');
	S out = "";
	for(const auto& x : parts) {
//		CERR "PART [" << x << "]" ENDL;
		char c = (char)std::stoi(x);
		
		// if we want to remap to a reasonable space...
		c = 48 + (c%(128-48));
		
		out += S(1,c);
	}
	return out;
}


int main(int argc, char** argv){ 
	using namespace std;
	
	// default include to process a bunch of global variables: mcts_steps, mcc_steps, etc
	auto app = Fleet::DefaultArguments("List functions");
	app.add_option("-a,--alphabet", alphabet, "Alphabet we will use"); 	// add my own args
	CLI11_PARSE(app, argc, argv);
	
	top.set_size(ntop); // set by above macro

	Fleet_initialize(); // must happen afer args are processed since the alphabet is in the grammar
	
	// declare a grammar
	MyGrammar grammar;
	
	//------------------
	// set up the data
	//------------------
	
	{
		
		FILE* fp = fopen(input_path.c_str(), "r");
		if(fp==NULL) { fprintf(stderr, "*** ERROR: Cannot open file!"); exit(1);}
		char* line = NULL; size_t len=0; 
		while( getline(&line, &len, fp) != -1 ) {
			if( line[0] == '#' ) continue;  // skip comments
			line[strcspn(line, "\n")] = 0; // remove newline
			
			// convert 1,2,3 format to 123 (separate chars)
			// NOTE: FOR NOW we take everything in the ascii range 48-90
			
			auto io = split(S(line),';');
			assert(io.size() == 2 && "*** Did not get exactly two parts (input/output) in data");
//			CERR "IO=" TAB io[0] TAB io[1] ENDL;
			auto i = decomma(io[0]);
			auto o = decomma(io[1]);
			
			COUT "# using data " << i <<" -> "<< o ENDL;
			
			mydata.push_back( MyHypothesis::t_datum({i, o}) );
		}
		fclose(fp);

	}
	COUT "# Starting run " ENDL;
	
	//------------------
	// Run
	//------------------
	
//
//	MyHypothesis h0(&grammar);
//	h0 = h0.restart();
//	auto thechain = MCMCChain(h0, &mydata, top);
//	thechain.run(mcmc_steps, runtime);
//	
	MyHypothesis h0(&grammar);
	h0 = h0.restart();
	ParallelTempering samp(h0, &mydata, top, nchains, 1000.0);
	tic();
	samp.run(mcmc_steps, runtime, 1.0, 5.0); //30000);		
	tic();

//	MyHypothesis h0(&grammar);
//	h0 = h0.restart();
//	auto thechain = ChainPool(h0, &mydata, top, nchains);
//	thechain.run(mcmc_steps, runtime);

//	auto h0 = new MyHypothesis(&grammar, nullptr); // start with empty node
// 	MCTSNode<MyHypothesis> m(explore, h0, playout);
//	tic();
//	m.parallel_search(nthreads, mcts_steps, runtime);
//	tic();
//	m.print("tree.txt");
	
	// Show the best we've found
	top.print();
	
	COUT "# Global sample count:" TAB FleetStatistics::global_sample_count ENDL;
	COUT "# Elapsed time:" TAB elapsed_seconds() << " seconds " ENDL;
	COUT "# Samples per second:" TAB FleetStatistics::global_sample_count/elapsed_seconds() ENDL;
	
}