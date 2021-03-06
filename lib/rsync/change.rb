module Rsync
  # Provides details about changes made to a specific file.
  #
  # Change Flags:
  #
  #  :no_change
  #  :identical
  #  :new
  #  :unknown
  #  :changed
  class Change
    def initialize(data)
      @data = data
    end

    # The filename associated with this change.
    # @return [String]
    def filename
      matches = @data.match /^.{9,11}\s(.*)$/
      matches[1]
    end

    # Whether the file was changed or not.
    # @return [Boolean]
    def changed?
      if update_type == :no_update
        false
      else
        true
      end
    end

    # Simple description of the change.
    # @return [String]
    def summary
      if update_type == :message
        message
      elsif update_type == :recv and @data[2,7] == "+++++++"
        "creating local"
      elsif update_type == :recv
        "updating local"
      elsif update_type == :sent and @data[2,7] == "+++++++"
        "creating remote"
      elsif update_type == :sent
        "updating remote"
      else
        changes = []
        [:checksum, :size, :timestamp, :permissions, :owner, :group, :acl].each do |prop|
          changes << prop if send(prop) == :changed
        end
        changes.join(", ")
      end
    end

    # @!group Change Flags

    # The change, if any, to the checksum of the file.
    # @return [Symbol]
    def checksum
      attribute_prop(2)
    end

    # The change, if any, to the size of the file.
    # @return [Symbol]
    def size
      attribute_prop(3)
    end

    # The change, if any, to the timestamp of the file.
    # @return [Symbol]
    def timestamp
      attribute_prop(4)
    end

    # The change, if any, to the file permissions.
    # @return [Symbol]
    def permissions
      attribute_prop(5)
    end

    # The change, if any, to the owner of the file.
    # @return [Symbol]
    def owner
      attribute_prop(6)
    end

    # The change, if any, to the group of the file.
    # @return [Symbol]
    def group
      attribute_prop(7)
    end

    # The change, if any, to the file ACL.
    # @return [Symbol]
    def acl
      attribute_prop(9)
    end

    # The change, if any, to the file's extended attributes.
    # @return [Symbol]
    def ext_attr
      attribute_prop(10)
    end

    # @!endgroup

    # The type of update made to the file.
    #
    #  :sent
    #  :recv
    #  :change
    #  :hard_link
    #  :no_update
    #  :message
    #
    # @return [Symbol]
    def update_type
      case raw_update_type
        when '<'
          :sent
        when '>'
          :recv
        when 'c'
          :change
        when 'h'
          :hard_link
        when '.'
          :no_update
        when '*'
          :message
      end
    end

    # The type of file.
    #
    #  :file
    #  :directory
    #  :symlink
    #  :device
    #  :special
    #
    # @return [Symbol]
    def file_type
      case raw_file_type
        when 'f'
          :file
        when 'd'
          :directory
        when 'L'
          :symlink
        when 'D'
          :device
        when 'S'
          :special
      end
    end

private

    def message
      @data[1..10].strip
    end

    def raw_update_type
      @data[0,1]
    end

    def raw_file_type
      @data[1,1]
    end

    def attribute_prop(index)
      case @data[index,1]
        when '.'
          :no_change
        when ' '
          :identical
        when '+'
          :new
        when '?'
          :unknown
        else
          :changed
      end
    end

  end
end
