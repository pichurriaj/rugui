require 'Qt4'

module Qt
  def Qt.create_application
    @@application = Qt::Application.new(ARGV)
  end

  def Qt.application
    @@application
  end
end

Qt.create_application

module RuGUI
  module FrameworkAdapters
    module Qt4
      class BaseController
        def queue(&block)
          block.call
        end
      end

      class BaseMainController < RuGUI::FrameworkAdapters::Qt4::BaseController
        def run
          Qt.application.exec
        end

        def quit
          Qt.application.exit
        end
      end

      class BaseView
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
          block.call
        end

        # Adds a widget to the given container widget.
        def add_widget_to_container(widget, container_widget)
          widget.parent = container_widget
        end

        # Removes a widget from the given container widget.
        def remove_widget_from_container(widget, container_widget)
          widget.dispose
        end

        # Removes all children from the given container widget.
        def remove_all_children(container_widget)
          container_widget.children.each do |child|
            child.dispose
          end
        end

        # Sets the widget name for the given widget if given.
        def set_widget_name(widget, widget_name)
          widget.object_name = widget_name
        end

        # Autoconnects signals handlers for the view. If +other_target+ is given
        # it is used instead of the view itself.
        def autoconnect_signals(view, other_target = nil)
        end
      end
    end
  end
end

module RuGUI
  class BaseView < BaseObject
    # An utility method to connect Qt signals between two Qt::Object.
    def connect(sender, signal, receiver, slot)
      sender = from_widget_or_name(sender)
      receiver = from_widget_or_name(receiver)
      if receiver.is_a?(Qt::Object)
        Qt::Object.connect(sender, SIGNAL(signal), receiver, SLOT(slot))
      else
        sender.connect(SIGNAL(signal)) { |*args| receiver.send(slot, *args) if respond_to?(slot) }
      end
    end
  end
end