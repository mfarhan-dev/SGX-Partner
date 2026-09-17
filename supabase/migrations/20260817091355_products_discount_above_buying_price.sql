-- Discount price must not go below cost. products_discount_below_customer_price
-- already guards the top; this guards the bottom. Same "backstop the client
-- validation in the database" pattern used everywhere else in this schema.
alter table public.products
  add constraint products_discount_above_buying_price
  check (discount_price is null or discount_price > buying_price);
