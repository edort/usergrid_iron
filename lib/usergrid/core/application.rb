module Usergrid
  class Application < Resource

    def initialize(url, options={})
      org_name = url.split('/')[-2]
      api_url = url[0..url.index(org_name)-2]
      super url, api_url, options
    end

    # note: collection_name s/b plural, but the server will change it if not
    def create_entity(collection_name, entity_data)
      self[collection_name].post entity_data
    end
    alias_method :create_entities, :create_entity

    # allow create_something(hash_or_array) method
    def method_missing(method, *args, &block)
      method_s = method.to_s
      if method_s.start_with? 'create_'
        entity = method_s.split('_')[1]
        return _create_user *args if entity == 'user' && args[0].is_a?(String) # backwards compatibility
        create_entity entity, *args
      elsif method_s.end_with? 's' # shortcut for retrieving collections
        self[method].query(*args)
      else
        super method, args, block
      end
    end

    def counter_names
      self['counters'].get.data.data
    end

    # other_params: 'start_time' (ms), 'end_time' (ms), 'resolution' (minutes)
    def counter(name, other_params={})
      options = other_params.merge({counter: name})
      self['counters'].get({params: options})
    end

    private

    def _create_user(username, password, email=nil, name=nil, invite=false)
      LOG.warn "create_user(username, password, ...) is deprecated"
      user_hash = { username: username,
                    password: password,
                    email: email,
                    name: name,
                    invite: invite }
      create_entity 'users', user_hash
    end

  end
end
