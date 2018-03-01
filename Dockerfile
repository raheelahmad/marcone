FROM swift:4.0.3
RUN apt-get -qq update && apt-get -q -y install \ 
  postgresql postgresql-client postgresql-contrib libpq-dev

WORKDIR /app

COPY Package.swift ./
RUN swift package fetch

COPY Sources ./Sources

RUN swift build
CMD ./.build/debug/marcone
