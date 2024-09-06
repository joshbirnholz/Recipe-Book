#  Recipe Book

## Build tools & versions used

Built using Xcode 15.4.

## Steps to run the app

Change the team Xcode's Signing and Capabilities settings, and then build and run the Recipe Book target.

## Dependencies Used

This project uses [CachedAsyncImage](https://github.com/lorenzofiamingo/swiftui-cached-async-image), a drop-in replacement for AsyncImage that caches images automatically. Recipe images are cached in-memory and to disk so they load more quickly on subsequent launches.
