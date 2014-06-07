#!/usr/bin/env bin/crystal --run
require "../../spec_helper"

describe "Code gen: struct" do
  it "creates structs" do
    run("
      struct Foo
      end

      f = Foo.allocate
      1
      ").to_i.should eq(1)
  end

  it "creates structs with instance var" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end
      end

      f = Foo.new(1)
      f.x
      ").to_i.should eq(1)
  end

  it "assigning a struct makes a copy (1)" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end

        def x=(@x)
        end
      end

      f = Foo.new(1)

      g = f
      g.x = 2

      g.x
      ").to_i.should eq(2)
  end

  it "assigning a struct makes a copy (2)" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end

        def x=(@x)
        end
      end

      f = Foo.new(1)

      g = f
      g.x = 2

      f.x
      ").to_i.should eq(1)
  end

  it "passes a struct as a parameter makes a copy" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end

        def x=(@x)
        end
      end

      def foo(f)
        f.x = 2
      end

      f = Foo.new(1)

      foo(f)

      f.x
      ").to_i.should eq(1)
  end

  it "passes a generic struct as a parameter makes a copy" do
    run("
      struct Foo(T)
        def initialize(@x)
        end

        def x
          @x
        end

        def x=(@x)
        end
      end

      def foo(f)
        f.x = 2
      end

      f = Foo(Int32).new(1)

      foo(f)

      f.x
      ").to_i.should eq(1)
  end

  it "returns struct as a copy" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end

        def x=(@x)
        end
      end

      def foo(f)
        f.x = 2
        f
      end

      f = Foo.new(1)

      g = foo(f)
      g.x
      ").to_i.should eq(2)
  end

  it "creates struct in def" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end
      end

      def foo
        Foo.new(1)
      end

      foo.x
      ").to_i.should eq(1)
  end

  it "declares const struct" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end
      end

      FOO = Foo.new(1)

      FOO.x
      ").to_i.should eq(1)
  end

  it "uses struct in if" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end
      end

      FOO = Foo.new(1)

      if 1 == 2
        $foo = Foo.new(1)
      else
        $foo = FOO
      end
      $foo.x
      ").to_i.should eq(1)
  end

  it "uses nilable struct" do
    run("
      struct Nil
        def nil?
          true
        end
      end

      struct Value
        def nil?
          false
        end
      end

      struct Foo
      end

      f = Foo.new || nil
      f.nil? ? 1 : 2
      ").to_i.should eq(2)
  end

  it "returns self" do
    run("
      struct Foo
        def initialize(@x)
        end

        def foo
          @x = 2
          return self
        end

        def x
          @x
        end
      end

      f = Foo.new(1)
      g = f.foo
      g.x
      ").to_i.should eq(2)
  end

  it "returns self with block" do
    run("
      struct Foo
        def initialize(@x)
        end

        def foo
          @x = 2
          yield 1
          self
        end

        def x
          @x
        end
      end

      f = Foo.new(1)
      g = f.foo { }
      g.x
      ").to_i.should eq(2)
  end

  it "does phi of struct" do
    run("
      struct Foo
        def initialize(@x)
        end

        def x
          @x
        end
      end

      x = if 1 == 2
            Foo.new(2)
          else
            Foo.new(1)
          end
      x.x
      ").to_i.should eq(1)
  end

  it "does == for empty struct" do
    run("
      struct Foo
      end

      Foo.new == Foo.new
      ").to_b.should be_true
  end

  it "does == for one-field struct (1)" do
    run("
      struct Foo
        def initialize(@x)
        end
      end

      Foo.new(1) == Foo.new(1)
      ").to_b.should be_true
  end

  it "does == for one-field struct (2)" do
    run("
      struct Foo
        def initialize(@x)
        end
      end

      Foo.new(1) == Foo.new(2)
      ").to_b.should be_false
  end

  it "does == for two-field struct (1)" do
    run("
      struct Foo
        def initialize(@x, @y)
        end
      end

      Foo.new(1, 2) == Foo.new(1, 2)
      ").to_b.should be_true
  end

  it "does == for two-field struct (2)" do
    run("
      struct Foo
        def initialize(@x, @y)
        end
      end

      Foo.new(1, 2) == Foo.new(1, 1)
      ").to_b.should be_false
  end

  it "does to_s for empty struct" do
    run("
      require \"prelude\"

      struct Foo
      end

      Foo.new.to_s
      ").to_string.should eq("Foo()")
  end

  it "does to_s for one field struct" do
    run("
      require \"prelude\"

      struct Foo
        def initialize(@x)
        end
      end

      Foo.new(1).to_s
      ").to_string.should eq("Foo(@x=1)")
  end

  it "does to_s for two field struct" do
    run("
      require \"prelude\"

      struct Foo
        def initialize(@x, @y)
        end
      end

      Foo.new(1, 2).to_s
      ").to_string.should eq("Foo(@x=1, @y=2)")
  end
end
