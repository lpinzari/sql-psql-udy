CREATE OR REPLACE FUNCTION gaussian(x double precision,
                                    mu double precision,
                                    sigma double precision,
                                 OUT val double precision )
RETURNS double precision
language plpgsql
AS $$
BEGIN
  SELECT CASE WHEN $3 > 0
              THEN EXP(-1.0*(x-mu)*(x-mu)/(2*sigma*sigma))/(sigma*SQRT(2*PI()))
              ELSE 0
         END INTO val;
  END;
$$;
