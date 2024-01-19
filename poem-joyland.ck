//------------------------------------------------------------------------------
// name: poem-joyland.ck
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
//       glove-wiki-gigaword-50.txt (400000 words x 2 dimensions)
//
//
// "Joyland"
//
// author: Samantha Liu
// date: Spring 2024
//------------------------------------------------------------------------------

// random seed (if set, sequence can be reproduce)
// Math.srandom( 515 );

// instantiate
Word2Vec model;
// pre-trained model to load
me.dir() + "glove-wiki-gigaword-50.txt" => string filepath;
// load pre-trained model (see URLs above for download)
if( !model.load( filepath ) )
{
    <<< "cannot load model:", filepath >>>;
    me.exit();
}

// timing
200::ms => dur T_UNIT; // duration per word
8 => int UNIT_PER_CHORD;

// sound
// rhodey does the solo
Rhodey rho => dac;
[67, 69, 71, 72, 74, 76, 79] @=> int pitches[];
[1, 2, 2, 2, 3, 4, 4, 4, 8] @=> int lengths[];
// krystlChr does the background
// array of krystal choir instruments
6 => int NUM_KRYSTLS;
KrstlChr c[NUM_KRYSTLS];
Pan2 p[NUM_KRYSTLS];
NRev r[2] => dac;
// connect up
for (int i; i < NUM_KRYSTLS; i++) {
   c[i] => p[i] => r;
   -1.0 + 0.333*i => p[i].pan;
   Math.random2f(2.5,4.0) => c[i].lfoSpeed; // different modulations
}
// turn down the volum... for safety
0.12 => r[0].gain => r[1].gain; 

// make a ConsoleInput
ConsoleInput in;
// tokenizer
StringTokenizer tok;
// line
string line[0];

// state
0 => int GET_TEXT;
1 => int GET_NUM;
GET_TEXT => int state;
// prompt
string prompt;
// the line 
string theText[0];

// new line
endl();
// print program name
chout <= "\"Joyland\"" <= IO.newline();
chout <= "---------" <= IO.newline();
chout.flush();
// new line
endl();

// loop
while( true )
{
    if( state == GET_TEXT )
    {
        "Enter something you can never say => " => prompt;
    }
    else
    {
        "Enter how many times you want to say it => " => prompt;
    }
    // prompt
    in.prompt( prompt ) => now;
    
    // read
    while( in.more() )
    {
        // clear tokens array
        line.clear();
        // clear if in text input mode
        if( state == GET_TEXT ) theText.clear();
        // get the input line as one string; send to tokenizer
        tok.set( in.getLine() );
        // tokenize line into words separated by white space
        while( tok.more() )
        {
            // put into array (lowercased)
            line << tok.next().lower();
            // copy into our text for later
            if( state == GET_TEXT ) theText << line[line.size()-1];
        }
        // if non-empty
        if( !line.size() )
            continue;
        
        // check state
        if( state == GET_TEXT )
        {
            // set state to GET_NUM
            GET_NUM => state;
        }
        else // GET_NUM
        {
            // check input
            Std.atoi( line[0] ) => int n;
            // make sure in range
            if( n <= 0 ) continue;

            spork ~ paraphrase( theText, n ) @=> Shred @ s;
            roll_krystl(s);
            say("Joyland"); play_wait();
            say("was"); play_wait();
            say("a"); play_wait();
            say("good"); play_wait();
            say("movie."); play_wait();
            // endline
            endl(); endl();

            // reset state to get text
            GET_TEXT => state;
        }
    }
}

fun void paraphrase( string input[], int iterations )
{
    string word;
    // search for iterations+5 similar words for each input word
    string words[input.size()][0];
    for (int i; i < input.size(); i++) {
        string temps[iterations+5];
        model.getSimilar( input[i], iterations+5, temps );
        // for (int j; j < temps.size(); j++) {
        //     <<< temps[j]>>>;
        // }
        // don't add the similar words that contain the input word
        for (int j; j < temps.size(); j++) {
            if (temps[j].find(input[i]) == -1) {
                words[i] << temps[j];
            }
        }
    }

    // each iteration updates one word from the previous
    for( int i; i < iterations; i++ )
    {
        for( int j; j < input.size(); j++ )
        {
            Math.random2(0, words[j].size()-i-1) => int ind;
            // <<< "j = ", j, "ind = ", ind>>>;
            words[j][ind] => word;
            say(word);
            play(pitches[Math.random2(0, pitches.size() - 1)]);
            wait(lengths[Math.random2(0, lengths.size() - 1)]);
        }
        endl();
    }
}



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
fun void wait()
{
    wait( 1 );
}

// wait
fun void wait( int num_units )
{    
    // let time pass, let sound...sound
    num_units * T_UNIT => now;
}

// new line with timing
fun void endl()
{
    endl( T_UNIT );
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
    pitch => Std.mtof => rho.freq;
    // note on
    0.8 => rho.noteOn;
}

fun void play_wait()
{
    play(pitches[Math.random2(0, pitches.size() - 1)]);
    wait(lengths[Math.random2(0, lengths.size() - 1)]);
}

fun void roll_krystl(Shred @ s) {
    while (s.done() != 1) {
        [36, 43, 40, 36, 31, 28] @=> int C[];
        [36, 45, 40, 36, 33, 28] @=> int Am[];
        [35, 43, 40, 35, 31, 28] @=> int Em[];
        rollChord(C); UNIT_PER_CHORD*T_UNIT => now; allOff(); UNIT_PER_CHORD*T_UNIT => now;
        rollChord(Am); UNIT_PER_CHORD*T_UNIT => now; allOff(); UNIT_PER_CHORD*T_UNIT => now;
        rollChord(Em); UNIT_PER_CHORD*T_UNIT => now; allOff(); UNIT_PER_CHORD*T_UNIT => now;
        UNIT_PER_CHORD*T_UNIT => now;
    }
}

fun void rollChord( int chord[] )
{
    for( int i; i < c.size(); i++ )
    {
        Std.mtof(chord[i] + 12) => c[i].freq;
        0.8 => c[i].noteOn;
        Math.random2f(0.1,0.3)::second => now;
    }
}

fun void allOff()
{
    for (int i; i < c.size(); i++) 1 => c[i].noteOff;
}