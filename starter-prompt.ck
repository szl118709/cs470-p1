//------------------------------------------------------------------------------
// name: starter-prompt.ck
// desc: vanilla starter code for an interactive prompt
//       + a continuous generating sound as example
// NOTE: this needs to run from command line chuck
//       (due to ConsoleInput)
//       > chuck starter-prompt.ck
//
// author: Ge Wang
// date: Spring 2023
//------------------------------------------------------------------------------

// make a ConsoleInput
ConsoleInput in;
// tokenizer
StringTokenizer tok;
// line
string line[0];

// sound
ModalBar bar => NRev reverb => dac;
.1 => reverb.mix;

// ding!
7 => bar.preset;

// spork to run a function in parellel
spork ~ background();

// some background
fun void background()
{
    while( true )
    {
        // set pitch to middle C
        Math.random2(48,72) => Std.mtof => bar.freq;
        // ding!
        Math.random2f(.5,1) => bar.noteOn;
        // advance time
        500::ms => now;
    }
}

// loop
while( true )
{
    // prompt
    in.prompt( "CUSTOMIZABLE PROMPT > " ) => now;
    
    // read
    while( in.more() )
    {
        // clear tokens array
        line.clear();
        // get the input line as one string; send to tokenizer
        tok.set( in.getLine() );
        // tokenize line into words separated by white space
        while( tok.more() )
        {
            // put into array (lowercased)
            line << tok.next().lower();
        }

        // at this point, for example,
        // "I like caTs" becomes ["i", "like", "cats"]
        // this array of strings are stored in 'line'
         
        // if non-empty
        if( line.size() )
        {
            // do something with the input
            execute( line );
        }
    }
}

// do something with the text input 
fun void execute( string input[] )
{
    // you can either start using the input creatively
    // OR you can use it to build a command prompt, e.g.,
    if( input[0] == "exit" || input[0] == "quit" )
    {
        // print
        <<< "bye!", "" >>>;
        me.exit();
    }

    // for now, just echo the input
    for( int i; i < input.size(); i++ )
    { cherr <= input[i] <= " "; }
    // new link
    cherr <= IO.newline();
}