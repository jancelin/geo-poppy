create table trame (
id serial,
jour date,
heure timestamp without time zone,
latitude numeric,
longitude numeric,
geom geometry(Point,4326),
Constraint pk_tramle PRIMARY KEY (id)
);

CREATE INDEX index_trame_geom
  ON public.trame
  USING gist
  (geom);
