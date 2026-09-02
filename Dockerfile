# Minimal PHP + Swoole for Semitexa (project is mounted at runtime)
#
# PCOV is installed but DISABLED by default (zz-pcov.ini). Coverage is opt-in:
#   php -d pcov.enabled=1 vendor/bin/phpunit <paths> --coverage-text
#
# PCOV rather than Xdebug deliberately: Xdebug is known to conflict with Swoole
# coroutines, which is this framework's entire runtime, and PCOV is far cheaper on
# a large suite. Enabled by default it would make every ordinary test run pay for
# coverage nobody asked for.
#
# directory and initial.files are set explicitly rather than left to PCOV's
# defaults, because those defaults FAIL SILENTLY on a project of any size: an
# empty pcov.directory with initial.files=64 produces a clean run reporting 0.00%
# over thousands of classes, with no error and no warning.
FROM php:8.4-cli-alpine

# Install Composer from official image (multi-stage, no extra dependencies)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

ARG IMAGICK_VERSION=3.8.1

RUN apk add --no-cache autoconf g++ make linux-headers openssl-dev git unzip imagemagick-dev imagemagick-webp imagemagick-jpeg imagemagick-heic \
    && docker-php-ext-install pdo pdo_mysql sockets \
    && pecl install --nobuild swoole \
    && cd "$(pecl config-get temp_dir)/swoole" \
    && phpize && ./configure --enable-openssl --disable-brotli --disable-zstd \
    && make -j$(nproc) && make install \
    && docker-php-ext-enable swoole \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install imagick-"${IMAGICK_VERSION}" \
    && docker-php-ext-enable imagick \
    && pecl install pcov \
    && docker-php-ext-enable pcov \
    && printf 'pcov.enabled=0\npcov.directory=/var/www/html\npcov.initial.files=20000\n' > /usr/local/etc/php/conf.d/zz-pcov.ini \
    && addgroup -g 1000 -S semitexa \
    && adduser -u 1000 -S -G semitexa -h /var/www/html semitexa

# Node, as a SEPARATE layer on purpose: it lands after the Swoole build above, so
# adding or changing it re-uses that cached layer instead of recompiling Swoole.
#
# It exists for the server/client render parity test in semitexa-ssr.
# semitexa-twig.js renders deferred slots in the browser while PHP Twig renders
# them on the server, and the only honest way to prove the two agree is to execute
# both on the same input. Without node the test SKIPS rather than fails, so a
# release gate would go green having never checked parity at all.
RUN apk add --no-cache nodejs

WORKDIR /var/www/html

USER semitexa

CMD ["php", "server.php"]
