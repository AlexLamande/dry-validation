require 'dry/validation/constants'

module Dry
  module Validation
    class Result
      include Dry::Equalizer(:output, :messages)
      include Enumerable

      attr_reader :output
      attr_reader :errors
      attr_reader :error_compiler
      attr_reader :hint_compiler
      attr_reader :path

      alias_method :to_hash, :output
      alias_method :to_h, :output # for MRI 2.0, remove it when drop support

      def initialize(output, errors, error_compiler, hint_compiler, path)
        @output = output
        @errors = errors
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
        @path = path
        @messages = EMPTY_HASH if success?
      end

      def each(&block)
        output.each(&block)
      end

      def [](name)
        output.fetch(name)
      end

      def success?
        errors.empty?
      end

      def failure?
        !success?
      end

      def messages(options = EMPTY_HASH)
        message_set(options).dump
      end

      def message_set(options = EMPTY_HASH)
        error_compiler
          .with(options).(error_ast)
          .with_hints!(hint_compiler.with(options).())
      end

      def to_ast(*)
        if path.size > 0
          [type, [name, [:path, [name, [:set, error_ast]]]]]
        else
          [:set, error_ast]
        end
      end

      def name
        Array(path).last
      end

      private

      def type
        success? ? :success : :failure
      end

      def error_ast
        @error_ast ||= errors.map { |error| error.to_ast }
      end
    end
  end
end
