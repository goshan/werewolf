@Wolf = @Wolf ? {}

class @Wolf.Utils
  @varIsNull: (p) ->
    typeof(p) == 'undefined' || p == null

  @arrayIsEmpty: (arr) ->
    typeof(arr) == 'undefined' || arr == null || arr.length == 0
