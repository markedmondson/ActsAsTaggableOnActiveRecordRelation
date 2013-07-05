module ActsAsTaggableOnBulk

  # Add a list of tags to an ActiveRecord::Relation
  def add_tags(tags,context=nil)
    return self if tags.empty?
    data = prepare_transaction_for_tagging(tags, context)
    ActsAsTaggableOn::Tagging.transaction do
      columns = [:tag_id, :taggable_id, :taggable_type, :context]

      all_values = data[:resources_ids].reduce([]) do |values, resource_id|
        data[:tags_ids].each do |tag_id|
          values << [tag_id, resource_id, data[:resource_name], data[:context_value]]
        end
        values
      end

      ActsAsTaggableOn::Tagging.import(columns, all_values, validate: false, on_duplicate_key_update: columns)
    end
    self
  end

  # Add one tag to an ActiveRecord::Relation
  def add_tag(tag, context=nil)
    add_tags([tag], context)
  end

  # Remove a list of tags from an ActiveRecord::Relation
  def remove_tags(tags,context=nil)
    return self if tags.empty?
    data = prepare_transaction_for_tagging(tags, context)
    ActsAsTaggableOn::Tagging.where({
      taggable_type:  data[:resource_name],
      taggable_id:    data[:resources_ids],
      tag_id:         data[:tags_ids],
      context:        context
    }).delete_all
    self
  end

  # Remove one tag from an ActiveRecord::Relation
  def remove_tag(tag, context=nil)
    remove_tags([tag], context)
  end

  private

  # Filter an array and returns only ActsAsTaggableOn::Tag objects
  def filter_list_to_tags(tag_list)
    strings = tag_list.reject{|t| t unless t.kind_of?(String) }
    tags    = tag_list.reject{|t| t unless t.kind_of?(ActsAsTaggableOn::Tag) }
    tags   += ActsAsTaggableOn::Tag.find_or_create_all_with_like_by_name(strings) unless strings.empty?
    tags
  end

  # Filter the given array and returns only ActsAsTaggableOn::Tag list
  def prepare_transaction_for_tagging(tags, context=nil)
    filtered_tags = filter_list_to_tags(tags)
    {
      tags_ids:       filtered_tags.map{|item| item.id},
      resources_ids:  self.pluck("#{self.table_name}.id"),
      resource_name:  self.klass.to_s,
      context_value:  context_value = context
    }
  end

end
