/*
 Produces the normal deviate z corresponding to a give lower tail area of p;
 z is accurate to about 1 part in 10**7:
 Link pub: https://csg.sph.umich.edu/abecasis/gas_power_calculator/algorithm-as-241-the-percentage-points-of-the-normal-distribution.pdf
*/

CREATE OR REPLACE FUNCTION qnorm(p double precision,
                                 OUT z double precision )
                  RETURNS double precision
                  language plpgsql
                AS
$$
 DECLARE
  zero constant double precision := 0.0E0;
  one constant double precision := 1.0E0;
  half constant double precision := one/2.0E0;
  split1 constant double precision := 0.425E0;
  split2 constant double precision := 5.0E0;
  const1 constant double precision := 0.180625E0;
  const2 constant double precision := 1.6E0;

  -- Coefficients for p close to 1/2
  a0 constant double precision := 3.3871327179E0;
  a1 constant double precision := 5.0434271938E1;
  a2 constant double precision := 1.5929113202E2;
  a3 constant double precision := 5.9109374720E1;
  b1 constant double precision := 1.7895169469E1;
  b2 constant double precision := 7.8757757664E1;
  b3 constant double precision := 6.7187563600E1;
  -- Hash sum AB = 32.3184577772

  -- Coefficients for p neither close to 1/2 nor 0 or 1
  c0 constant double precision := 1.4234372777E0;
  c1 constant double precision := 2.7568153900E0;
  c2 constant double precision := 1.3067284816E0;
  c3 constant double precision := 1.7023821103E-1;
  d1 constant double precision := 7.3700164250E-1;
  d2 constant double precision := 1.2021132975E-1;
  -- Hash sum CD = 15.7614929821

  -- Coefficients for p near 0 or 1
  e0 constant double precision := 6.6579051150E0;
  e1 constant double precision := 3.0812263860E0;
  e2 constant double precision := 4.2868294337E-1;
  e3 constant double precision := 1.7337203997E-2;
  f1 constant double precision := 2.4197894225E-1;
  f2 constant double precision := 1.2258202635E-2;
  -- Hash sum EF = 19.4052910204

  q double precision;
  r double precision;

  BEGIN
    q := p - half;

    /* |p~ - 0.5| <= .425  <==> 0.075 <= p~ <= 0.925 */
    IF (ABS(q) <= split1) THEN
       r := const1 - q*q;
       z := q*(((a3*r + a2)*r + a1)*r + a0)/(((b3*r + b2)*r + b1)*r + one);
    ELSE
       IF (q < 0) THEN
          r = p;
       ELSE
          r = one - p;
       END IF;

       IF (r > 0 ) THEN
          r = SQRT(-LN(r));
          IF (r <= split2) THEN
               r = r - const2;
               z = (((c3*r + c2)*r + c1)*r + c0)/((d2*r + d1)*r + one);
          ELSE
               r = r - split2;
               z = (((e3*r + e2)*r + e1)*r + e0)/((f2*r + f1)*r + one);
          END IF;
       ELSE
          z = 0;
       END IF;

       IF (q < 0) THEN
           z = -z;
       END IF;
    END IF;
  END;
$$;
