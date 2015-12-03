Eclipse Portable Launcher
=========================
Copyright 2004-2012 John T. Haller
Copyright 2008-2012 Brandon Cheng

Website: http://PortableApps.com/EclipsePortable

This software is OSI Certified Open Source Software.
OSI Certified is a certification mark of the Open Source Initiative.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

ABOUT ECLIPSE PORTABLE
======================
The Eclipse Portable Launcher allows you to run Eclipse from a removable drive
whose letter changes as you move it to another computer.  The browser and the
profile can be entirely self-contained on the drive and then used on any Windows
computer.

LICENSE
=======
This code is released under the GPL.  Within the EclipsePortableSource directory
you will find the code (EclipsePortable.nsi) as well as the full GPL license
(License.txt).  If you use the launcher or code in your own product, please give
proper and prominent attribution.


INSTALLATION / DIRECTORY STRUCTURE
==================================
By default, the program expects the following directory structure:

-\ <--- Directory with EclipsePortable.exe
	+\App\
		+\Eclipse\
	+\Data\
		+\workspace\
		+\settings\
		
The above files may also be placed in a EclipsePortable directory with the 
EclipsePortable.exe launcher a directory above that.

It can be used in other directory configurations by including the EclipsePortable.ini
file in the same directory as EclipsePortable.exe and configuring it as detailed in
the INI file section below.


ECLIPSEPORTABLE.INI CONFIGURATION
=================================
The Eclipse Portable Launcher will look for an ini file called EclipsePortable.ini
within its directory.  If you are happy with the default options, it is not necessary,
though.  There is an example INI included with this package to get you started.  The
INI file is formatted as follows:

[EclipsePortable]
EclipseDirectory=App\Eclipse
EclipseExecutable=eclipse.exe
SettingsDirectory=Data\settings
JavaPath=..\CommonFiles\Java\bin\javaw.exe
MinGWPath=..\CommonFiles\MinGW\bin
AdditionalPaths=..\MSYSPortable\App\MSYS\bin
AdditionalParameters=

The EclipseExecutable entry allows you to set the Eclipse Portable Launcher to use
an alternate EXE call to launch Eclipse.  This is helpful if you are using a machine
that is set to deny Eclipse.exe from running.  You'll need to rename the Eclipse.exe
file and then enter the name you gave it on the EclipseExecutable= line of the INI.

The SettingsDirectory entries should be set to the *relative* path to the directories
containing Eclipse.exe, your profile, your plugins, etc. from the current  directory.
All must be a subdirectory (or multiple subdirectories) of the directory containing
EclipsePortable.exe.  The default entries for these are described in the installation
section above.

The JavaPath is the place where Java is on the drive. Each ".." will tell Eclipse to 
go up a directory from the Eclipse Portable folder. This way, you can run Eclipse
on Computers where java has not been installed.

The AdditionalPaths are directiries you would like Eclipse Portable to add to the PATH
environment variable on startup. This may be MSYS, Git, or GTK+. Separate paths with a
semicolon (;).

The AdditionalParameters entry allows you to pass additional commandline parameter
entries to Eclipse.exe.  Whatever you enter here will be appended to the call to
Eclipse.exe.

