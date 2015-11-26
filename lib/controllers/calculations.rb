$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'yaml'

module Calculations

  CONS = YAML::load_file("../config/constants.yml")

  def elapsed_time_since_ingress(ingress_time)
    Time.now - ingress_time
  end

  def elapsed_time_since_fa(ingress_time, speed)
    Time.now - ingress_time - time_ingress_to_fa(speed)
  end

  def distance_traveled(speed, start_time, end_time)
    speed * ( end_time - start_time ).to_f
  end

  def total_descent(ingress_altitude)
    ingress_altitude - CONS['fa_altitude']
  end

  def slope(ingress_altitude)
    ( ingress_altitude.to_f - CONS['fa_altitude'] ) /
      ( CONS['descent_h_distance'] )
  end

  def position(ingress_altitude, raw_distance)
    s = slope( ingress_altitude )
    d = Math.sqrt( raw_distance.to_f**2 / ( 1 + s**2 ) )
    d = raw_distance
    x = (2.1e-12 * d**3) - (4.41e-6 * d**2) + (0.047 * d) + 16000
    y = (2.23e-14 * d**4) - (2e-9 * d**3) + (1.02e-4 * d**2) - (5 * d) + 47000
    return [x, y]
  end

  def time_ingress_to_fa(speed)
    CONS['descent_distance'].to_f / speed
  end

  def time_fa_to_land(speed)
    ( 2 * CONS['fa_distance'].to_f ) / ( speed + CONS['landing_speed'] )
  end

  def altitude(ingress_altitude, ingress_time, end_time, speed)
    if ( speed * ( end_time - ingress_time ) ) <= CONS['descent_distance']
      descent_duration = CONS['descent_distance'].to_f / speed
      descent_rate = total_descent( ingress_altitude ) / descent_duration
      return ingress_altitude -
        ( elapsed_time_since_ingress( ingress_time ) * descent_rate )
    else
      descent_rate = CONS['fa_altitude'] / time_fa_to_land(speed)
      return CONS['fa_altitude'] -
        ( elapsed_time_since_fa( ingress_time, speed ) * descent_rate )
    end
  end
end