FROM jekyll/jekyll:3
COPY . /srv/jekyll/
RUN  jekyll build
ENTRYPOINT [ "jekyll", "serve", "--incremental", "--watch"]
EXPOSE 4000