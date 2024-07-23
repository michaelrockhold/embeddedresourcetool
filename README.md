#  Embedded Resource Tool

This tiny project demonstrates how to embedded arbitrary data resources 
into the binary file of a command-line tool. This demo is specific to
applying this technique in the context of developing macOS or iOS tools,
but the general principle is valid for Linux and Unixes; it's entirely
unnecessary in developing for Windows, where a similar technique is just the
normal way loading resources works.

## Why is this interesting?
This is a helpful technique when you want to develop a single-binary program, as
opposed to when you might build an application packaged as a bundle. Say you're
building a command-line tool, and your program depends on a number of template files
that the user applies to his/her own data. You have a couple of options:

 1) Supply the template files along with the executable; this is not a terrible option,
 especially when the user may want to customize the templates, or make and use new ones.
 But it has downsides, in particular in complicating installation and maintainence of your
 program.
 
 2) Turn the template files into Swift (or ObjC, or Pascal, or whatever) code structures, and
 make them available to your program that way; this is pretty convenient, and in some ways the
 most straightforward way. But there problems with this: all the templates are taking up space
 in your program, and are all in memory whether the user ever uses them or not. Also, your templates
 are now Swift (or whatever) code, and maybe that in itself is suboptimal, if it's more appropriate
 to maintain them in their own native environment (say they are some custom forms language or something).
 Finally, perhaps those templates are generated on the fly at build time? That just complicates your
 build process, and might even make it more fragile.
 
 3) (You knew I'd get here eventually) Arrange to have Xcode embed them directly in the single executable
 file that is your program. Now you've got a single file to deploy, not a bundle, and not an executable-plus-
 some-templates-plus-an-installer-script. In effect, we are giving your simple command-line tool some
 of the convenience that applications have when they can use the Bundle API to pull in the various
 resources that that developer just through into the app bundle.

## How Do I Do It?
There are three parts to this.
 1) (Build time) Generate your resources. In your project's target, you'll find the "Build Phases". Make
 a new one, of the "Run Script" variety, and make that script do whatever is most appropriate, with the
 goal of creating a file in the $(__DERIVED_FILE_DIR__) directory. Use the Run Script phase editor to designate
 the output file, so that Xcode can track the dependencies among the build phases.
 
 You can have one script generate all the resources that you're embedding, or you can have one script for each
 resource. Just make sure all the Run Script build phases are arranged to run _before_ the "Compile Sources"
 build phase. Xcode seems to get its dependencies tangled up otherwise.
 
 2) (Also Build time) Tweak the link phase. By editing the __OTHER_LDFLAGS__ build setting for your target,
 you can instruct the linker to create new TEXT (not necessarily text, actually; it's historical) sections
 in your tool's binary for each resource. The contents of the files your build created in the previous step will be 
 copied verbatim into their section.
 
 3) (Run time!) When your program needs to load the embedded resources, it just has to inspect it's own binary
 file (the MachOKit package makes this very easy, so that's what I used in this demo), and load the data for
 the resource from the appropriate area of the binary file.
 
 Keep in mind that this is a verbatim copy of what was in the resource file you created at build time. For things
 like text files or even images, that might be all you need. For more interesting use cases, you may need to think
 about how to move program objects from one domain to another. You may find it convenient in these cases to 
 remember the (Codable)[https://developer.apple.com/documentation/swift/codable] protocol, and how to create Codable JSON structures.
 Or what about (grpc)[https://en.wikipedia.org/wiki/GRPC], when JSON can't cut it?
 Or (Thrift)[https://en.wikipedia.org/wiki/Apache_Thrift], for the deeply masochistic?

## Who Did This?
I'm Michael Rockhold, a coder in Seattle. I consult on projects for macOS and iOS, some embedded platforms, and some clouds. Have a look at my (resume)[https://michaelrockhold.github.io/CV/]! (A little out of date, actually. It's on my to-do list)
