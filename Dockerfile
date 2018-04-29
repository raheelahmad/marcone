FROM swift:4.1
RUN apt-get -qq update && apt-get -q -y install \ 
  postgresql postgresql-client postgresql-contrib libpq-dev

WORKDIR /app

COPY Package.swift ./
COPY Package.resolved ./
RUN swift package fetch

COPY Sources ./Sources
COPY Tests ./Tests

CMD swift run
