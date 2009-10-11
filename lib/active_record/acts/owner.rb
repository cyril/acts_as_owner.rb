module ActiveRecord
  module Acts
    module Owner
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Configuration resources are: all resources belonging to the current model.
        def acts_as_owner(*resources)
          resources.each { |resource| has_many resource.to_s.tableize, :dependent => :destroy }

          class_eval <<-EOV
            include ActiveRecord::Acts::Owner::InstanceMethods

            def self.owns_many
              reflections.select { |name, reflection| reflection.macro == :has_many }.collect { |table| table[0].to_s.singularize }
            end
          EOV
        end
      end

      module InstanceMethods
        # Returns true if the user owns the object which can be a account or a resource.  Otherwise returns false.
        def owns?(object = nil)
          object.is_a?(self.class) ? self.owns_this_account?(object) : self.owns_this_resource?(object)
        end

        protected

        # Returns true if the user owns the account, otherwise returns false.
        def owns_this_account?(account)
          self.id == account.id
        end

        # Returns true if the user owns the resource, otherwise returns false.
        def owns_this_resource?(resource)
          self.respond_to?(resource.class.name.tableize) && self.send(resource.class.name.tableize).include?(resource) || parents_of(resource).collect { |parent| owns_this_resource?(parent) }.select { |result| result == true }.uniq.pop == true
        end

        # Returns an array of resources that are:
        #  * directly superior to the resource passed as parameter, according the hierarchical tree structure;
        #  * potentially owned by the current user, through the hierarchical relationship.
        def parents_of(resource)
          potential_owners_of(resource).collect { |method| resource.send(method) }
        end

        # Returns an array containing symbols common to children which belongs to self class and to parents which has many given resource.
        def potential_owners_of(resource)
          self.class.owns_many & resource.class.reflections.select { |name, reflection| reflection.macro == :belongs_to }.collect { |table| table[0].to_s }
        end
      end
    end
  end
end
