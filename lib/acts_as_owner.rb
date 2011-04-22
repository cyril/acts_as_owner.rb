module ActsAsOwner
  def owns?(obj)
    can_own_this?(obj) if self.class.could_own_a?(obj.class.name.underscore)
  end

  protected

  def can_own_this?(obj, depth = 0)
    association_id = obj.class.name.tableize.singularize.to_sym
    association_params = self.class.
      read_inheritable_attribute(:ownable_ids)[association_id]

    unless depth > association_params[:max_depth]
      owner_id = association_params[:owner_id]
      owned = obj.respond_to?(owner_id) && obj.send(owner_id) == self

      owned || ownable_ancestors(obj).any? do |name|
        can_own_this?(name, depth.next)
      end
    end
  end

  def ownable_ancestors(child)
    ancestors = child.class.reflections.select do |name, reflection|
      reflection.macro == :belongs_to
    end

    ancestors.map {|table| table.first }.
      select {|name| self.class.could_own_a?(name) }.
      map {|name| child.send(name) }.compact
  end
end

class ActiveRecord::Base
  def self.acts_as_owner(options = {}, &block)
    configuration = {
      :max_depth => 50,
      :owner_id  => name.tableize.singularize.to_sym }
    configuration.update(options) if options.is_a?(Hash)

    write_inheritable_hash(:ownership_options, configuration)
    write_inheritable_hash(:ownable_ids, {})

    class << self
      def owns_many(association_id, options = {})
        read_inheritable_attribute(:ownable_ids).update({
          association_id.to_s.singularize.to_sym =>
            read_inheritable_attribute(:ownership_options).merge(options) })
      end

      def owns_one(association_id, options = {})
        read_inheritable_attribute(:ownable_ids).update({
          association_id.to_sym =>
            read_inheritable_attribute(:ownership_options).merge(options) })
      end

      def could_own_a?(association_id)
        read_inheritable_attribute(:ownable_ids).keys.
          include?(association_id.to_sym)
      end

      alias_method :could_own_an?, :could_own_a?
    end

    instance_eval &block

    include ActsAsOwner
  end
end
