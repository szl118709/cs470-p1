//------------------------------------------------------------------------------
// name: poem-inspirator.ck
//
// version: need chuck version 1.5.0.0 or higher
// sorting: part of ChAI (ChucK for AI)
//
// NOTE: because this example needs ConsoleInput, it needs to
//       run command line chuck
//       > chuck poem-inspirator.ck
//
// NOTE: need a pre-trained word vector model, e.g., from
//       https://chuck.stanford.edu/chai/data/glove/
//       glove-wiki-gigaword-50-tsne-2.txt (400000 words x 2 dimensions)
//
//
// "Inspirator"
//
// author: Samantha Liu
// date: Spring 2024
//------------------------------------------------------------------------------

// random seed (if set, sequence can be reproduce)
// Math.srandom( 515 );

// instantiate
Word2Vec model;
// pre-trained model to load
me.dir() + "glove-wiki-gigaword-50-tsne-2.txt" => string filepath;
// load pre-trained model (see URLs above for download)
if( !model.load( filepath ) )
{
    <<< "cannot load model:", filepath >>>;
    me.exit();
}

// timing
10::ms => dur T_UNIT; // duration per word
10 => int NUM_INSPOS;

// sound
ModalBar bar => dac;
[42, 43, 45, 47, 48, 50, 52, 54, 55, 57] @=> int pitches[];
[1, 2, 2, 2, 4, 4] @=> int lengths[];

// make a ConsoleInput
ConsoleInput in;
// tokenizer
StringTokenizer tok;
// line
string line[0];

// prompt
string prompt;

// new line
endl();
// print program name
chout <= "\"Inspirator\"" <= IO.newline();
chout <= "-----an inspiration generator-----" <= IO.newline();
chout.flush();
// new line
endl();

// prompt
in.prompt( "Enter some potential lyrics: " ) => now;

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
        
    // if non-empty
    if( line.size() )
    {
        Math.random2( 0, 8 ) => bar.preset;
        get_inspired( line );
    }
}

fun void get_inspired(string input[]) {
    for (int k; k < NUM_INSPOS; k++) {
        for ( int i; i < input.size(); i++ ) {
            say(input[i]); 
            (input[i].length() + 2) / 3 => int syllables; // on average, 3 chars per syllable
            for (int j; j < syllables; j++) {
                play(pitches[Math.random2(0, pitches.size() - 1)]);
                wait(lengths[Math.random2(0, lengths.size() - 1)]);
            }
        }
        endl();
    }
}

// ----- helpers -----
// say a word with space after
fun void say( string word )
{
    say( word, " " );
}

// say a word
fun void say( string word, string append )
{
    // print it
    chout <= word <= append; chout.flush();
}

// wait
fun void wait( int num_units )
{    
    // let time pass, let sound...sound
    num_units * T_UNIT => now;
}

// just a new line
fun void endl0() {
    chout <= IO.newline(); chout.flush();
}

// new line with timing
fun void endl()
{
    endl( 8 * T_UNIT );
}

// new line with timing
fun void endl( dur T )
{
    // new line
    chout <= IO.newline(); chout.flush();
    // let time pass
    T => now;
}

// sonify
fun void play( int pitch )
{
    // convert pitch to frequency and set it
    pitch => Std.mtof => bar.freq;
    // note on
    0.8 => bar.noteOn;
}