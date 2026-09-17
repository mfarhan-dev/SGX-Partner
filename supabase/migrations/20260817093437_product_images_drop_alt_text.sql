-- Unused: no admin field ever wrote to it, no query ever read it. Alt text
-- for product photos should be derived from the product name at render
-- time when the customer app actually displays these images, not
-- hand-typed per photo into a column nobody was going to fill in.
alter table public.product_images
  drop column alt_text;
