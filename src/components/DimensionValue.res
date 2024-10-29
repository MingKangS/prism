%raw(`require('../styles/DimensionValue.css')`)

let trimTrailingZeros = (input: string): string => {
  let formatted = Js.Float.toString(Js.Float.fromString(input))
  formatted->Js.String2.replaceByRe(Js.Re.fromString("/\\.0+$|(\.\d*?)0+$/"), "$1")
}

@react.component
let make = (
  ~isEditMode: bool,
  ~value: string,
  ~metric: string,
  ~setCurrentEditingDimension: unit => unit,
  ~onSaveNewDimensionValue: (string, string) => unit,
) => {
  let isDefaultValue = value == "auto"
  let (editValue, setEditValue) = React.useState(() => "")
  let (editMetric, setEditMetric) = React.useState(() => "px")

  let handleInputChange = event => {
    let newValue = ReactEvent.Form.currentTarget(event)["value"]

    setEditValue(_ => newValue)
  }

  let handleMetricChange = event => {
    let newMetric = ReactEvent.Form.currentTarget(event)["value"]

    setEditMetric(_ => newMetric)
  }

  let handleClickValue = () => {
    setCurrentEditingDimension()
    setEditValue(_ => isDefaultValue ? "0" : value)
  }

  let metricOptions = ["px", "%"]

  let selectMetricOptions = Array.map(option => {
    <option key={option} value={option}> {React.string(option)} </option>
  }, metricOptions)

  <div>
    {isEditMode
      ? <div className="input-wrapper">
          <input
            type_="number"
            className="value-input"
            value=editValue
            onChange=handleInputChange
            onBlur={_ => onSaveNewDimensionValue(editValue, editMetric)}
          />
          <select
            value={editMetric}
            onChange={handleMetricChange}
            onBlur={_ => onSaveNewDimensionValue(editValue, editMetric)}>
            {React.array(selectMetricOptions)}
          </select>
        </div>
      : <span className={isDefaultValue ? "default" : "changed"} onClick={_ => handleClickValue()}>
          {React.string(isDefaultValue ? value : trimTrailingZeros(value))}
          {isDefaultValue ? React.string("") : React.string(metric)}
        </span>}
  </div>
}
