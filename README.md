# Red Community

[![Join the chat at https://gitter.im/red/community](https://badges.gitter.im/red/community.svg)](https://gitter.im/red/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is a resource for Red users and members of the community. Generally that
means software developers of some kind, so you'll find information targeted
mainly at that audience. But Red can be used by anybody, for many different
purposes. You don't need to be a professional developer to use the resources
here.

As a resource repository for Red developers, you'll find scripts, tools, demos,
documenation, tutorials, and more, all contributed by members of the Red
community. It's more open than the official Red and Red Code repositories, where
people can post demos of things they've written in Red, as well as reusable
functions, libraries, and tools for others to use.

All over the world that are major initiatives to get more and younger children actively programming. Red's virtues of small size, syntax that encourages understandable code and its built-in GUI will undoubtedly attract children. Please bear this in mind when submitting any contributions or chatting about them.

# Organisation

Currently the repository has a very simple structure, one folder for Red code and another for separate Red/System code.

# Submitting Scripts and Code

A separate Github Pull Request should be made for each script that you wish to submit.

The scripts should follow the [Red coding style guide](https://github.com/red/red/wiki/Coding-Style-Guide).

The submission should include a valid [Red Community Code Header](#Community-Code-Headers).

## Community Code Headers

Each entry should have a valid header that includes at least:

### Red header: Author
The real name of the author must be supplied as a string. 

### Red header: File
The name of the script, program, library -- eg %my-script.red, %yet-another-map.red, or %roman-numerals.reds

File should follow these conventions

Start with a percentage sign, %, like any other Red file!
Contain only lower-case letters, digits, or hyphens. This ensures cross-platform compatibility
Don't start or end with a hyphen (%-my-script and %myscript.red- are not good)
Should have a suffix (eg .red or .reds). It doesn't need to be .red or .reds, but that is strongly recommended
Not be a reserved file name for any of the platforms that Red programs run on (e.g. con or lpt1 are reserved under Windows)
For a new script, has a name that does not clash with any other script in the Library

### Red header: Date
Should be a valid Red date. It really should be the date of submission to the repository, eg Date: 14-May-2017.
(Until the date! datatype is available in Red, the date should be enclosed in "s.)

### Red header: Title
A short string that descibes the script.

### Red header: Purpose
A string, possibly multi-line, that briefly describes the script. Purpose is optional, but highly recommended.

### Red header: License
Conditions under which the script can be used. See http://www.opensource.org/licenses/index.html for information about various open source licenses. A string, lit-word, block, or none.

Standard licenses are:

bsd cc-by cc-by-sa gpl lgpl
mit pd public-domain rvd 

### Red header: Copyright
The standard Copyright field should also be used if appropriate. It is optional.

### Red header: Comm-Code
This is part of the Red or Red/System header. It includes additional information to describe your code. A basic commcode header looks like this:

    comm-code: [
        level: 'intermediate
        platform: 'all
        type: [tutorial tool]
        domain: [ftp game]
        tested-under: none
    ]

The comm-code header is optional. You do not need it, but it does help people to more easily find code that is relevant to their needs. 

### Comm-Code header: Level
A single quoted word to say what level of user expertise is embodied in the script. That is, the level of Red understanding that a user should have. It doesn't have anything to do with the domain-specific aspects of an entry. Use any one of:
advanced beginner intermediate

beginner - These should be understandable even to those that are just evaluating REBOL. We don't want to scare off newcomers.

intermediate - This assumes a basic working knowledge of REBOL and the ability to use HELP and SOURCE to learn more. Script size isn't as important as complexity. That is to say, scripts can be large as long as they are straight-forward.

advanced - Examples of things that fall into this category would be: higher order functions, USE blocks - beyond very obvious usage, BIND, anonymous functions - again beyond very basic usage of the mechanism, dynamic layout generation in View, etc.

### Comm-Code header: Platform
The platform(s) on which this script will run. Can be a lit-word or block. Use any combination of:

*nix all android linux
macOS raspi solaris unix win
windows 

Examples
Platform: [linux windows *nix]

Platform: 'android

Most scripts will have no platform specified, which means they are expected (though not guaranteed) to work on any platform their target REBOL product runs on.

### Comm-Code Library header: Type
Says the type of code, or how it is used. What its purpose is. Can be a lit-word or block. Use any combination of:

article demo dialect faq fun
function game how-to idiom module
one-liner package protocol rebcode reference
tool tutorial 

Examples
Type: [how-to idiom]

Type: 'rebcode

Type: [protocol idiom faq]

Applications
These are things you can just click and see something happen. They may be useful or not.

Demo - These are written to show Red off in some way. You may learn something from their code, but their goal is to just look cool and show off. All demos will have a display of some kind, even if it's just a console. 

Tool - Tools and Utilities provide some kind of useful functionality. Some of them may also be good demos, easy-vid being a classic example. Effect-lab is another good example, because it shows you the effect block it's building up and you can copy it out for your own use.

Game - Games are games. If you can play it, it's a game.

Idiom - These are the little nuggets that show you the inner 'zen' of Red. e.g. How do I concatenate strings? or How do I upload a file with FTP? Idiom entries should be small and well focused.

Code
This is the area for things that don't do anything on their own.

One-liner - If it fits on one line, it qualifies.

Function - A function or a set of functions that can be called or included in other scripts. They usually return a result.

Module - A function (or set of functions) that does something. Generally these would define a context/namespace to avoid collisions.

Protocol - A full-blown protocol. 

Dialect - Some dialect scripts might also fall into other categories. It doesn't necessarily mean that all they do is provide a dialect (i.e. set of parse rules). It just means that a dialect of some kind is a prominent component of the functionality, though it may also be just a set of parse rules (and docs to go with them of course).

Mode of running
Rebcode - Ther script runs in the Rebcode Virtual Machine.

### Comm-Code header: Domain
What application area(s) the script addresses. All scripts should have at least one domain that they applies to them, and they may have more than one.

Can be a lit-word or block. Use any combination of:

ai animation broken cgi compression
database db dead debug dialects
email encryption extension external-library file-handling
files financial ftp game graphics
gui html http ldc markup
math mysql odbc other-net parse
patch printing protocol scheme scientific
sdk security shell sound sql
ssl tcp testing text text-processing
ui user-interface vid visualization web
win-api x-file xml 

Examples
Domain: [text-processing file-handling security]

Domain: 'parse

Domain: [dialects debug mysql xml files]

# Disclaimer

The resources here are not reviewed, and therefore could
contain harmful data. All downloaded resources should be examined before
execution to ensure that they are not malicious in intent.

Everything here is provided AS IS without any warranty and without any liability.

Happy Reducing!


