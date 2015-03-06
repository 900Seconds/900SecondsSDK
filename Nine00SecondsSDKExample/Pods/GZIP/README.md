[![Build Status](https://travis-ci.org/nicklockwood/GZIP.svg)](https://travis-ci.org/nicklockwood/GZIP)


Purpose
--------------

GZIP is category on NSData that provides simple gzip compression and decompression functionality.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 8.0 / Mac OS 10.9 (Xcode 6.0, Apple LLVM compiler 6.0)
* Earliest supported deployment target - iOS 5.0 / Mac OS 10.7
* Earliest compatible deployment target - iOS 4.3 / Mac OS 10.6

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

The GZIP category will work correctly in either ARC or non-ARC projects without modification.


Thread Safety
--------------

All the GZIP methods should be safe to call from multiple threads concurrently.


Installation
--------------

To use the GZIP category in an app, just drag the category files (test files and assets are not needed) into your project and import the header file into any class where you wish to make use of the GZIP functionality. You will also need to include the libz.dylib.


NSData Extensions
----------------------

    - (NSData *)gzippedDataWithCompressionLevel:(float)level;

This method will apply the gzip deflate algorithm and return the compressed data. The compression level is a floating point value between 0.0 and 1.0, with 0.0 meaning no compression and 1.0 meaning maximum compression.  A value of 0.1 will provide the fastest possible compression. If you supply a negative value, this will apply the default compression level, which is equivalent to a value of around 0.7.

    - (NSData *)gzippedData;
    
This method is equivalent to calling `gzippedDataWithCompressionLevel:` with the default compression level.
    
    - (NSData *)gunzippedData;
    
This method will unzip data that was compressed using the deflate algorithm and return the result.


Release Notes
--------------

Version 1.0.3

- Fixed new warnings in Xcode 6
- Added Travis CI support

Version 1.0.2

- Now complies with -Weverything warning level

Version 1.0.1

- Added podspec
- Renamed source files
- Verified compliance with iOS 7 / Mac OS 10.8
- Verified compliance with -Wextra warning level

Version 1.0

- Initial release.