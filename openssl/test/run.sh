#!/bin/bash
set -e

MAIN_TARGETS=https://static.rust-lang.org/dist

if [ "$TEST_FEATURES" == "true" ]; then
    FEATURES="tlsv1_2 tlsv1_1 dtlsv1 dtlsv1_2 sslv3 aes_xts aes_ctr npn alpn rfc5114 ecdh_auto pkcs5_pbkdf2_hmac x509_clone ssl_context_clone x509_generator_request hmac hmac_clone dh_from_params x509_expiry"
fi

if [ "$TRAVIS_OS_NAME" != "osx" ]; then
    export OPENSSL_LIB_DIR=$HOME/openssl/lib
    export OPENSSL_INCLUDE_DIR=$HOME/openssl/include
    export LD_LIBRARY_PATH=$HOME/openssl/lib:$LD_LIBRARY_PATH
fi

if [ -n "$TARGET" ]; then
    FLAGS="--target=$TARGET"
    COMMAND="build"

    # Download the rustlib folder from the relevant portion of main distribution's
    # tarballs.
    dir=rust-std-$TARGET
    pkg=rust-std
    curl -s $MAIN_TARGETS/$pkg-$TRAVIS_RUST_VERSION-$TARGET.tar.gz | \
      tar xzf - -C $HOME/rust/lib/rustlib --strip-components=4 \
        $pkg-$TRAVIS_RUST_VERSION-$TARGET/$dir/lib/rustlib/$TARGET
else
    COMMAND="test"
fi

export PATH=$HOME/openssl/bin:$PATH
(cd openssl && RUST_BACKTRACE=1 cargo $COMMAND $FLAGS --features "$FEATURES")
