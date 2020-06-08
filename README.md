# FIPS 140-2 Endpoint Test

This simple CLI tool checks a provided endpoint against NIST and FedRAMP approved ciphers that are supported by OpenSSL. I recommend the following items to achieve FIPS 140-2 compliant endpoints:

- Use TLS 1.2 or greater. TLS 1.0 and TLS 1.1 are deprecated by NIST and set to be unapproved in 2023.
- Do not use SSLv2 or SSLv3
- Do not use weak or null ciphers
- The operating system should be in FIPS 140-2 mode, running a FIPS 140-2 validated version (`1.0.2k-fips`) of OpenSSL

To view the list of approved ciphers, run the following command:

```bash
./testfips.sh list-approved
```

To view the list of deprecated ciphers, run the following command:

```bash
./testfips.sh list-approved
```

## Usage

The CLI is implemented in bash and the only requirements are bash and OpenSSL. The script does not require the FIPS version of OpenSSL as this is a simple cipher check.

```bash
./testfips.sh help
```

**Example:**
```bash
./testfips.sh run s3-fips.us-gov-west-1.amazonaws.com
```

## What is FIPS 140-2?

The Federal Information Processing Standard Publication 140-2, FIPS PUB 140-2, is a U.S. government computer security standard used to approve cryptographic modules. The title is Security Requirements for Cryptographic Modules. Initial publication was on May 25, 2001 and was last updated December 3, 2002.

For more information, visit the [FIPS 140-2 Wikipedia Page](https://en.wikipedia.org/wiki/FIPS_140-2).

## License

This library is licensed under the MIT-0 License. See the [LICENSE file](./LICENSE).
