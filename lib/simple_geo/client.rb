module SimpleGeo
  
  class Endpoint
    
    class << self
      def record(layer, id)
        endpoint_url "records/#{layer}/#{id}.json"
      end
    
      def records(layer, ids)
         ids = ids.join(',')  if ids.is_a? Array
         endpoint_url "records/#{layer}/#{ids}.json"
      end
    
      def add_records(layer)
        endpoint_url "records/#{layer}.json"
      end
    
      def history(layer, id)
        endpoint_url "records/#{layer}/#{id}/history.json"
      end
    
      def nearby(layer, geohash)
        endpoint_url "records/#{layer}/nearby/#{geohash}.json"
      end
    
      def nearby_address(lat, lon)
        endpoint_url "nearby/address/#{lat},#{lon}.json"
      end
    
      def density(lat, lon, day, hour=nil)
        if hour.nil?
          path = "density/#{day}/#{lat},#{lon}.json"
        else
          path = "density/#{day}/#{hour}/#{lat},#{lon}.json"
        end
        endpoint_url path
      end
    
      def layer(layer)
        endpoint_url "layer/#{layer}.json"
      end
    
      def contains(lat, lon)
        endpoint_url "contains/#{lat},#{lon}.json"
      end
    
      def overlaps(south, west, north, east)
        endpoint_url "overlaps/#{south},#{west},#{north},#{east}.json"
      end
    
      def boundary(id)
        endpoint_url "boundary/#{id}.json"
      end
    
      def endpoint_url(path)
        [REALM, API_VERSION, path].join('/')
      end
    end
    
  end
  
  class Client

    @@connection = nil
    @@debug = false
    
    class << self
      
      def set_credentials(token, secret)
        @@connection = Connection.new(token, secret)
        @@connection.debug = @@debug
      end
      
      def debug=(debug_flag)
        @@debug = debug_flag
        @@connection.debug = @@debug  if @@connection
      end
      
      def debug
        @@debug
      end
      
      def add_record(record)
        raise SimpleGeoError, "Record has no layer"  if record.layer.nil?
        put Endpoint.record(record.layer, record.id), record
      end

      def delete_record(layer, id)
        delete Endpoint.record(layer, id)
      end

      def get_record(layer, id)
        record_hash = get Endpoint.record(layer, id)
        Record.parse_json(record_hash)
      end

      def add_records(layer, records)
        features = {
          :type => 'FeatureCollection',
          :features => records.collect { |record| record.to_hash }
        }
        post Endpoint.add_records(layer), "POST", features
      end
    
      def get_records(layer, ids)
        features = get Endpoint.records(layer, ids)
        features['features'] || []
      end

      def get_history(layer, id, options={})
        get Endpoint.history(layer, id), options
      end
      
      #TODO: get nearby by lat, lon 
      # api.simplegeo.com/{version}/records/{layer}/nearby/{lat},{lon}.json
      def get_nearby(layer, geohash, options={})
        get Endpoint.nearby(layer, geohash), options
      end
      
      def get_nearby_address(lat, lon)
        get Endpoint.nearby_address(lat, lon)
      end
      
      def get_layer_information(layer)
        get Endpoint.layer(layer)
      end
      
      def get_density(lat, lon, day, hour=nil)
        get Endpoint.density(lat, lon, day, hour)
      end

      def get_overlaps(south, west, north, east, options)
        get Endpoint.overlaps(south, west, north, east), options
      end

      def get_boundary(id)
        get Endpoint.boundary(id)
      end

      def get_contains(lat, lon)
        get Endpoint.contains(lat, lon)
      end

      def get(endpoint, data=nil)
        raise NoConnectionEstablished  if @@connection.nil?
        @@connection.get endpoint, data
      end

      def delete(endpoint, data=nil)
        raise NoConnectionEstablished  if @@connection.nil?
        @@connection.delete endpoint, data
      end

      def post(endpoint, data=nil)
        raise NoConnectionEstablished  if @@connection.nil?
        @@connection.post endpoint, data
      end

      def put(endpoint, data=nil)
        raise NoConnectionEstablished  if @@connection.nil?
        @@connection.put endpoint, data
      end
    end
    
  end
  
end
