require 'active_record/base'

module ActsAsOwner
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Configuration resources are: all resources belonging to the current model.
    def acts_as_owner(*resources)
      resources.each { |resource| has_many resource.to_s.tableize.to_sym, :dependent => :destroy }

      class_eval <<-EOV
        include ActsAsOwner::InstanceMethods

        def self.owns_many
          reflections.select { |name, reflection| reflection.macro == :has_many }.collect { |table| table[0].to_s.singularize }
        end

        def self.owns_one
          reflections.select { |name, reflection| reflection.macro == :has_one }.collect { |table| table[0].to_s.singularize }
        end
      EOV
    end
  end

  module InstanceMethods
    # Returns true if the user owns the object which can be a account or a resource.  Otherwise returns false.
    def owns?(object = nil)
      return false if object.nil?
      object.is_a?(self.class) ? self.owns_this_account?(object) : self.owns_this_resource?(object)
    end

    protected

    # Returns true if the user owns the account, otherwise returns false.
    def owns_this_account?(account)
      self.id == account.id
    end

    # Returns true if the user owns the resource, otherwise returns false.
    def owns_this_resource?(resource)
      (has_many?(resource) || has_one?(resource)) ||
      parents_of(resource).collect { |parent| owns_this_resource?(parent) }.select { |result| result == true }.uniq.pop == true
    end

    # Has many association
    def has_many?(resource)
      self.respond_to?(resource.class.name.tableize) && self.send(resource.class.name.tableize).include?(resource)
    end

    # Has one association
    def has_one?(resource)
      self.respond_to?(resource.class.name.tableize.singularize) && self.send(resource.class.name.tableize.singularize) == resource
    end

    # Returns an array of resources that are:
    #  * directly superior to the resource passed as parameter, according the hierarchical tree structure;
    #  * potentially owned by the current user, through the hierarchical relationship.
    def parents_of(resource)
      potential_owners_of(resource).collect { |method| resource.send(method) }
    end

    # Returns an array containing symbols common to children
    # which belongs to the current user and to parents which has many or has one given resource.
    def potential_owners_of(resource)
      (self.class.owns_many | self.class.owns_one) & resource.class.reflections.select do |name, reflection|
        reflection.macro == :belongs_to
      end.collect { |table| table[0].to_s }
    end
  end
end

ActiveRecord::Base.class_eval { include ActsAsOwner }