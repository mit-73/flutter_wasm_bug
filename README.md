`fvm flutter build web --wasm --no-strip-wasm`

`cd build/web`

`fvm dart pub global run dhttpd '--headers=Cross-Origin-Embedder-Policy=credentialless;Cross-Origin-Opener-Policy=same-origin'`

open browser: `localhost:8080 `
open devtools: `RuntimeError: memory access out of bounds`
