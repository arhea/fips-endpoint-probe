# FIPS 140-2 Endpoint Probe

This simple CLI tool checks a provided endpoint against NIST and FedRAMP approved ciphers that are supported by OpenSSL. I recommend the following items to achieve FIPS 140-2 compliant endpoints:

- Use TLS 1.2 or greater. TLS 1.0 and TLS 1.1 are no longer recommended.
- Do not use SSLv2 or SSLv3
- Do not use weak ciphers
- The operating system should be in FIPS mode, running a FIPS version (`1.0.2k-fips`) of OpenSSL, and using a load balancer that has been compiled with FIPS OpenSSL

Currently, the following ciphers are used for validation:

| Standard Name | OpenSSL Name | Version |
|---------------|--------------|---------|
| TLS_AES_256_GCM_SHA384 | TLS_AES_256_GCM_SHA384 | TLSv1.3 |
| TLS_CHACHA20_POLY1305_SHA256 | TLS_CHACHA20_POLY1305_SHA256 TLSv1.3 |
| TLS_AES_128_GCM_SHA256 | TLS_AES_128_GCM_SHA256 | TLSv1.3 |
| TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 | ECDHE-ECDSA-AES256-GCM-SHA384 TLSv1.2 |
| TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 | ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 |
| TLS_DHE_DSS_WITH_AES_256_GCM_SHA384 | DHE-DSS-AES256-GCM-SHA384 TLSv1.2 |
| TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 | DHE-RSA-AES256-GCM-SHA384 TLSv1.2 |
| TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 | ECDHE-ECDSA-AES128-GCM-SHA256 TLSv1.2 |
| TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 | ECDHE-RSA-AES128-GCM-SHA256 TLSv1.2 |
| TLS_DHE_DSS_WITH_AES_128_GCM_SHA256 | DHE-DSS-AES128-GCM-SHA256 TLSv1.2 |
| TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 | DHE-RSA-AES128-GCM-SHA256 TLSv1.2 |
| TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384 | ECDHE-ECDSA-AES256-SHA384 TLSv1.2 |
| TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 | ECDHE-RSA-AES256-SHA384 TLSv1.2 |
| TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 | DHE-RSA-AES256-SHA256 | TLSv1.2 |
| TLS_DHE_DSS_WITH_AES_256_CBC_SHA256 | DHE-DSS-AES256-SHA256 | TLSv1.2 |
| TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256 | ECDHE-ECDSA-AES128-SHA256 TLSv1.2 |
| TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 | ECDHE-RSA-AES128-SHA256 TLSv1.2 |
| TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 | DHE-RSA-AES128-SHA256 | TLSv1.2 |
| TLS_DHE_DSS_WITH_AES_128_CBC_SHA256 | DHE-DSS-AES128-SHA256 | TLSv1.2 |
| TLS_RSA_PSK_WITH_AES_256_GCM_SHA384 | RSA-PSK-AES256-GCM-SHA384 TLSv1.2 |
| TLS_DHE_PSK_WITH_AES_256_GCM_SHA384 | DHE-PSK-AES256-GCM-SHA384 TLSv1.2 |
| TLS_RSA_WITH_AES_256_GCM_SHA384 | AES256-GCM-SHA384 | TLSv1.2 |
| TLS_PSK_WITH_AES_256_GCM_SHA384 | PSK-AES256-GCM-SHA384 | TLSv1.2 |
| TLS_RSA_PSK_WITH_AES_128_GCM_SHA256 | RSA-PSK-AES128-GCM-SHA256 TLSv1.2 |
| TLS_DHE_PSK_WITH_AES_128_GCM_SHA256 | DHE-PSK-AES128-GCM-SHA256 TLSv1.2 |
| TLS_RSA_WITH_AES_128_GCM_SHA256 | AES128-GCM-SHA256 | TLSv1.2 |
| TLS_PSK_WITH_AES_128_GCM_SHA256 | PSK-AES128-GCM-SHA256  | TLSv1.2 |
| TLS_RSA_WITH_AES_256_CBC_SHA256 | AES256-SHA256 | TLSv1.2 |
| TLS_RSA_WITH_AES_128_CBC_SHA256 | AES128-SHA256 | TLSv1.2 |

The above list was generated using the following command:

```bash
openssl ciphers 'TLSv1.2+FIPS:kRSA+FIPS:!SSLv3:!eNULL:!aNULL'
```

## Usage

The CLI is implemented in bash and the only requirements are bash and OpenSSL. The script does not require the FIPS version of OpenSSL as this is a simple cipher check.

```bash
./fips-cli.sh "<host>:<port>" "<path>"
```

**Example:**
```bash
./fips-cli.sh "s3-fips.us-gov-west-1.amazonaws.com:443" "/"
```

## What is FIPS 140-2?

The Federal Information Processing Standard Publication 140-2, (FIPS PUB 140-2),[1][2] is a U.S. government computer security standard used to approve cryptographic modules. The title is Security Requirements for Cryptographic Modules. Initial publication was on May 25, 2001 and was last updated December 3, 2002.

For more information, visit the [FIPS 140-2 Wikipedia Page](https://en.wikipedia.org/wiki/FIPS_140-2).

## License

This library is licensed under the MIT-0 License. See the [LICENSE file](./LICENSE).
