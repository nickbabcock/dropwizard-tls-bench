# Dropwizard TLS Benchmark

This repo contains the code, benchmark suite, and the analysis of using the Conscrypt JCE Security provider that is available to Dropwizard 1.3 users. See the complementary post, [Dropwizard 1.3 Upcoming TLS Improvements](https://nbsoftsolutions.com/blog/dropwizard-1-3-upcoming-tls-improvements) for additional background and information.

This repo also demonstrates how easy it is to add Conscrypt as the ALPN provider so one doesn't need to modify the boot class path with a JRE version specific jar.

## Benchmark

- Install Docker and Docker Compose
- Download and build [nghttp2](https://github.com/nghttp2/nghttp2) if an implementation is not available for your platform
- Execute `NGHTTP2_DIR=<PATH> ./bench.sh` as a user that can use docker and wait a couple hours
- Resulting benchmarks will be in `out.csv`
- Chart of the data can be see in `analysis.R`

## Results

Crunch `out.csv` anyway you want, but if you want to replicate the graph below, use `analysis.R`

![](https://github.com/nickbabcock/dropwizard-tls-bench/raw/master/dropwizard-tls.png)

For response / request payloads around 100KB or more, where most of the work comes from encrypting or decrypting a response (like in an echo server seen here), expect to see 7.5x throughput improvement for h2 services and 2.5x for HTTPS 1.1.
