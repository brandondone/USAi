#!/bin/bash

# Create Frameworks directory if it doesn't exist
mkdir -p build/bin/gpt4all.app/Contents/Frameworks

# Copy libraries to Frameworks directory
cp build/bin/libllamamodel-mainline-cpu.dylib \
   build/bin/libllamamodel-mainline-cpu-avxonly.dylib \
   build/bin/libllamamodel-mainline-metal.dylib \
   build/bin/libllmodel.dylib \
   build/bin/gpt4all.app/Contents/Frameworks/

# Update library paths
for lib in build/bin/gpt4all.app/Contents/Frameworks/*.dylib; do
    install_name_tool -id "@rpath/$(basename $lib)" "$lib"
done

# Add rpath to executable
install_name_tool -add_rpath "@executable_path/../Frameworks" build/bin/gpt4all.app/Contents/MacOS/gpt4all

echo "Library setup completed successfully!" 