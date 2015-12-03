Java binaries go here or in X:\PortableApps\CommonFiles\Java for shared use.

To enable Java, copy the Java files from a local install, usually C:\Program Files\Java\jre1.5.0_11,
to this directory.  Copy the whole structure intact (so you'd have a lib and a bin directory in this
Java directory when complete.

Then, create a text file called javaportable.ini in the same directory as this readme.txt with the
following in it (altering for Java version):

[JavaPortable]
Vendor=Sun Microsystems Inc.
Version=1.5.0_11
URL=http://java.sun.com/