# frozen_string_literal: true

class Route
  include InstanceCounter
  include Validation

  attr_reader :route

  validate :route, :presence
  validate :route, :comparison_min_length, 2

  def initialize(start_station, end_station)
    @route = [start_station, end_station]
    validate!
    route_validate!
    register_instance
  end

  def add_station(station)
    add_station_validate!(station)
    route.insert(route.length - 1, station)
  end

  def delete_station(station)
    delete_station_validate!(station)
    train_station_update(station)
    route.delete(station)
  end

  private

  attr_writer :route

  def train_station_update(station)
    station.trains.each { |train| station.send_train(train, true) if train.train_route == self }
  end

  def route_validate!
    raise 'First and last stations should be different!' if @route.first == @route.last

    @route.each { |station| raise "Object is't a station:\n#{station}" unless station.is_a? Station }
  end

  def add_station_validate!(station)
    raise "Route alredy include #{station}!" if route.include?(station)
  end

  def delete_station_validate!(station)
    raise "Route not include #{station}" unless route.include?(station)
    raise "Can't delete first or last station" if [route.first, route.last].include?(station)
  end
end
