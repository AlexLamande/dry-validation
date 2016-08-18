require 'dry/monads/either'
require 'dry/validation/constants'

module Dry
  module Validation
    class Result
      include Dry::Equalizer(:output, :messages)
      include Dry::Monads::Either::Mixin
      include Enumerable

      attr_reader :output
      attr_reader :errors
      attr_reader :error_compiler
      attr_reader :hint_compiler

      alias_method :to_hash, :output
      alias_method :to_h, :output # for MRI 2.0, remove it when drop support

      def initialize(output, errors, error_compiler, hint_compiler)
        @output = output
        @errors = errors
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
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

      def to_ast
        [:set, error_ast]
      end

      def to_either(options = EMPTY_HASH)
        if success?
          Right(output)
        else
          Left(messages(options))
        end
      end

      private

      def error_ast
        @error_ast ||= errors.map { |error| error.to_ast }
      end
    end
  end
end
