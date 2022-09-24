-- reference [formula](https://gist.github.com/olooney/b4b93436ee37875fbcefe0a9b5106e90)
CREATE OR REPLACE FUNCTION pnorm(z double precision,
                                 OUT val double precision )
RETURNS double precision
language plpgsql
AS $$
BEGIN
  SELECT CASE WHEN $1 >= 0
              THEN 1 -POWER(((((((0.000005383*$1+0.0000488906)*$1+0.0000380036)*$1+0.0032776263)*$1+0.0211410061)*$1+0.049867347)*$1+1),-16)/2
              ELSE 1 - pnorm(-$1)
         END INTO val;
  END;
$$;
