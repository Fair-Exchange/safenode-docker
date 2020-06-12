FROM safecoin/safecoin

ENV HOME /safenode
WORKDIR /safenode

RUN rm -rf /safecoin

COPY setup-safenode.sh /usr/bin/setup-safenode.sh
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 8770
EXPOSE 8771

ENTRYPOINT ["docker-entrypoint.sh"]
