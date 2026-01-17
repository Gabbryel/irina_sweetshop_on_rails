class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:user_id] = controller.try(:current_user).try(:id)
    super(data)
  end
end

# set to true for JavaScript tracking
Ahoy.api = true

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false

# Track visits and events
Ahoy.visit_duration = 4.hours
Ahoy.visitor_duration = 2.years
