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

All over the world that are major initiatives to get more and younger children actively programming. Red's virtues of small size, syntax that encourages understandable code and its built in GUI will undoubtedly attract children. Please bear this in mind when submitting any contributions or chatting about them.

# Organisation

Currently the repository has a very simple structure, one folder for Red code and another for separate Red/System code.

# Submitting Scripts and Code

A separate Github Pull Request should be made for each script that you wish to submit.

The scripts should follow the [Red coding style guide](https://github.com/red/red/wiki/Coding-Style-Guide).

The submission should include a valid [Red Community Code Header](#Community-Code-Headers).

## Community Code Headers

Each entry should have a valid header that includes at least:

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
A short string that descibes the script

### Red header: Purpose
A string, possibly multi-line, that briefly describes the script. Purpose is optional, but highly recommended.

### Red Comm-Code header
This is part of the Red or Red/System header. It includes additional information to describe your code. A basic commcode header looks like this:

    comm-code: [
        level: 'intermediate
        platform: 'all
        type: [tutorial tool]
        domain: [ftp game]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]

The Comm-code header is optional. You do not need it, but it does help people to more easily find code that is relevant to their needs. 

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
Library header: Plugin
If a script has a platform: [ ... plugin ...] entry (meaning it is certified as runnable under the REBOL browser plugin) it must also have a Library header of plugin to specify the settings needed by the plugin

Values are:

plugin: [size: pair! version: string!]

Where:

size -- the width and height of the window needed for the script to display properly. This value must be present. Minimum size is 100x100.
version -- specific version number of the plugin, if the script needs anything other than the most recent version
This is optional -- omit if you do not mind which version is run
The only version currently allowed is "http://www.rebol.com/plugin/rebolb4.cab#Version=0,5,0,0"
Example:

 rebol [ ... library: [ ... plugin: [size: 800x1000] ... ] ] 

Library header: Type
Says what type of thing the script is, or how it is used. What its purpose is. Can be a lit-word or block. Use any combination of:

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
Demo - These are written to show REBOL off in some way. Good examples are Cyphre's graphic demos, Doc's v-balls, gel, and splash. Yes, you may learn something from their code, but their goal is to just look cool and show off. All demos will have a display of some kind, even if it's just a console. Scripts like rebodex.r and to-do.r might fall into two categories with a small change. They are good demos as they come with sample data, but they could also be Utilities if you were allowed to change the data they contain and persist those changes. Calculator is both a demo and a utility.

Tool - Tools and Utilities provide some kind of useful functionality. Some of them may also be good demos, easy-vid being a classic example. Effect-lab is another good example, because it shows you the effect block it's building up and you can copy it out for your own use.

Game - Games are games. If you can play it, it's a game.

Documentation Related
Things in this category may be documents of some kind other than a REBOL script, though scripts may also be included. Their intent is to inform, teach, etc.
Reference - Non-script entries would be things like dictionary.html or the view developer's guide from RT. It would also apply to easy-vid, view-ref, and other "active" documents.

How-To - The new REBOL Cookbook is kind of in line with this. They can be code without a separate article, or explanatory text may be included.

FAQ - Answers to simple questions. May be code or not. More concise than How-To's, but along the same lines. They should fit well as answers to a "How do I...?" question.

Article - These are items that are mainly text, but may also contain code. They are targeted at informing people about REBOL, not being technical.

Tutorial - I'd classify the REBOL Forces Articles as tutorials. They are explanatory, but contain code. Longer and deeper than a How-To.

Idiom - These are the little nuggets that show you the inner 'zen' of REBOL. There may be overlap between FAQs, one-liners, and Idioms. e.g. How do I concatenate strings? or How do I upload a file with FTP? Idiom entries should be small and well focused.

Code
This is the area for things that don't do anything on their own.
One-liner - If it fits on one line, it qualifies.

Function - A function (like Round.r) or a set of functions (like prime.r) that can be called or included in other scripts. They usually return a result.

Module - A function (or set of functions) that does something (like lrwp.r or melt.r). Generally these would define a context/namespace to avoid collisions.

Protocol - A full-blown protocol (like mysql_all.r). You should be able to determine if something qualifies for this by looking for "make root-protocol" and/or "net-utils/net-install" in the source.

Dialect - Some dialect scripts might also fall into other categories. It doesn't necessarily mean that all they do is provide a dialect (i.e. set of parse rules). Andrew's ML stuff is a good example, as is make-doc. It just means that a dialect of some kind is a prominent component of the functionality, though it may also be just a set of parse rules (and docs to go with them of course).

Mode of running
Rebcode - Ther script runs in the Rebcode Virtual Machine.

Library header: Domain
What application area(s) the script addresses. All scripts should have at least one domain that they applies to them, and they may have more than one.

Not all application areas are "published". The user view, so far, is much more limited. i.e. just because we have a domain listed doesn't mean it will appear as its own group in the user interface of library tools or the web/html version.

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

Patch - A patch is an updated version of a mezzanine that ships with a standard REBOL distribution. Some of them will come from RT and others will come from users. There are a couple different reasons people write patches. For RT, it's a way to fix bugs without having to do an entire release of REBOL. Patches from RT are considered "official", but that doesn't mean they're perfect of course. Some patches change behavior because someone thinks the original behavior is incorrect, or inadequate. These have to be treated carefully as having patched functions that behave differently can be quite confusing. If you write a patch, make sure to comment it clearly as to what the purpose of the patch is.

Library header: Tested-under
Notes about the testing environment used. This field is designed to give people at least a hint about where the entry is known to work, or maybe that it wasn't tested at all. A string, block, or none.

NOTE:
We've talked briefly about the following dialect, but have not yet committed to it or updated existing scripts to use it. Comments are welcome.

    values: Given in groups, as follows:

        product version OS [opt notes] [opt tested-by]

    	product:   word! ; command view core base IOS SDK
    	version:   tuple!
    	OS:        opt 'on [word! | string! | block!]
    	notes:	   opt string!
    	tested-by: opt 'by [word! | string! | block!]

    example values:

    	tested-under: [core 2.5.3.3.1 W2K]
    	tested-under: [view 1.2.8.3.1 on "Windows 98"]
    	tested-under: [
    		command 1.2.5 on [Win2K Me 98] "Sunanda"
    		command 2.1.1 on [W2K]	  "Anton"
    		command 2.0.0 on [linux]  [Gregg Volker]
    	]
    	tested-under: [
            base 2.6.0 W2K {Patched in http protocol from Core 2.5.3} by GSI
        ]
      

Library header: Support
The standard header already contains a Home field, which should be used if it exists. The standard Author and EMail fields should also be used. The library Support field is there for the cases where the original author of an entry no longer supports it, or never did, but someone else steps up to fill that void. You may also include notes about any support you offer (e.g. "See my website for plug-ins"). A string, block, or none.

A block is the preferred format, since that makes it easy to include, and find, email addresses and URLs among the comments.
Library header: License
Conditions under which the script can be used. See http://www.opensource.org/licenses/index.html for information about various open source licenses. A string, lit-word, block, or none.

See help on choosing a license for more details.

The standard Copyright field should also be used if appropriate.

Standard licenses are:

bsd cc-by cc-by-sa gpl lgpl
mit pd public-domain rvd 

Library header: Replaced-by
This is an optional header -- most scripts will not have it. Use it only if you want to show that this script has been replaced by another.

Rules:

Format is a file name . eg replaced-by: %new-script.r
The replacing file must already exist in the Library (so add it first)
The replacing file must not itself have a replaced-by entry
You can't replace a script with itself (replaced-by script name must be different to the current script's)
Library header: See-also
Cross-reference to other scripts of interest. A string or none

Note:
We've talked about using this simple dialect:

 some [[file! | url!] opt string!] 

where file! values would be links to other library scripts, url! values would be links to external references, with optional notes included for each. Since things are still in flux, we haven't talked about how relative paths might be included and such.

# Disclaimer

The resources here are not guaranteed to be deeply reviewed, and therefore could
contain harmful data. All downloaded resources should be examined before
execution to ensure that they are not malicious in intent.

Everything here is provided AS IS without warranty and without liability to the
author or to FullStack Technologies.


Happy Reducing!


