%raw(`require('../styles/Prism.css')`)

type dimensionRecord = {
  component_id: int,
  dimension_name: string,
  value: string,
}

@react.component
let make = (~componentId: string) => {
  let (values, setValues) = React.useState(_ =>
    Js.Dict.fromArray([
      ("mt", "auto"),
      ("mr", "auto"),
      ("mb", "auto"),
      ("ml", "auto"),
      ("pt", "auto"),
      ("pr", "auto"),
      ("pb", "auto"),
      ("pl", "auto"),
    ])
  )

  let (metrics, setMetrics) = React.useState(_ =>
    Js.Dict.fromArray([
      ("mt", "px"),
      ("mr", "px"),
      ("mb", "px"),
      ("ml", "px"),
      ("pt", "px"),
      ("pr", "px"),
      ("pb", "px"),
      ("pl", "px"),
    ])
  )

  React.useEffect1(() => {
    Api.fetchDimension(~componentId)
    |> Js.Promise.then_(examplesJson => {
      let newValues = Js.Dict.fromArray(Js.Dict.entries(values))
      let newMetrics = Js.Dict.fromArray(Js.Dict.entries(metrics))

      switch Js.Json.decodeArray(examplesJson) {
      | Some(dimensionsArray) => Js.Array.forEach(dim => {
          switch Js.Json.decodeObject(dim) {
          | Some(dimObj) =>
            let dimensionName = switch Js.Dict.get(dimObj, "dimension_name") {
            | Some(jsonValue) => Js.Json.decodeString(jsonValue)
            | None => None
            }
            let value = switch Js.Dict.get(dimObj, "value") {
            | Some(jsonValue) => Js.Json.decodeString(jsonValue)
            | None => None
            }
            let metric = switch Js.Dict.get(dimObj, "metric") {
            | Some(jsonValue) => Js.Json.decodeString(jsonValue)
            | None => None
            }

            switch (dimensionName, value, metric) {
            | (Some(name), Some(val), Some(met)) => {
                Js.Dict.set(newValues, name, val)
                Js.Dict.set(newMetrics, name, met)
              }
            | _ => ()
            }
          | None => ()
          }
        }, dimensionsArray)
      | None => Js.log("Failed to decode JSON as an array")
      }

      setValues(_ => newValues)
      setMetrics(_ => newMetrics)
      Js.Promise.resolve()
    })
    |> ignore
    None
  }, [])

  let (currentEditingDimension, setCurrentEditingDimension) = React.useState(_ => "")

  let saveNewDimensionValue = (dimensionName, newValue, newMetric) => {
    setCurrentEditingDimension(_ => "")

    Api.saveDimension(~componentId, ~dimensionName, ~value=newValue, ~metric=newMetric)
    |> Js.Promise.then_(_ => {
      let updatedValues = Js.Dict.fromArray(Js.Dict.entries(values))
      Js.Dict.set(updatedValues, dimensionName, newValue)

      setValues(_ => updatedValues)

      let updatedMetrics = Js.Dict.fromArray(Js.Dict.entries(metrics))
      Js.Dict.set(updatedMetrics, dimensionName, newMetric)

      setMetrics(_ => updatedMetrics)

      Js.Promise.resolve()
    })
    |> ignore
  }

  let dimensionPositionToClassNameMap: Js.Dict.t<string> = Js.Dict.fromArray([
    ("t", "absolute-top"),
    ("r", "absolute-right"),
    ("b", "absolute-bottom"),
    ("l", "absolute-left"),
  ])

  let dimensionValues = (dimensionValuesArray: array<string>) =>
    Array.map(
      dimensionValueName =>
        <span
          className={Belt.Option.getWithDefault(
            Js.Dict.get(
              dimensionPositionToClassNameMap,
              String.make(1, String.get(dimensionValueName, 1)),
            ),
            "",
          ) ++ " absolute"}>
          <DimensionValue
            value={Belt.Option.getWithDefault(Js.Dict.get(values, dimensionValueName), "")}
            metric={Belt.Option.getWithDefault(Js.Dict.get(metrics, dimensionValueName), "")}
            isEditMode={currentEditingDimension == dimensionValueName}
            setCurrentEditingDimension={_ => setCurrentEditingDimension(_ => dimensionValueName)}
            onSaveNewDimensionValue={(newValue, metric) =>
              saveNewDimensionValue(dimensionValueName, newValue, metric)}
          />
        </span>,
      dimensionValuesArray,
    )

  <div className="container">
    {React.array(dimensionValues(["mt", "mr", "mb", "ml"]))}
    <div className="content"> {React.array(dimensionValues(["pt", "pr", "pb", "pl"]))} </div>
  </div>
}
