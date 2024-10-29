module Response = {
  type t

  @send
  external json: t => Js.Promise.t<Js.Json.t> = "json"

  @send
  external text: t => Js.Promise.t<string> = "text"

  @get
  external ok: t => bool = "ok"

  @get
  external status: t => int = "status"

  @get
  external statusText: t => string = "statusText"
}
type saveDimensionPayload = {
  value: string,
  dimensionName: string,
}

type options = {method: string, headers: Js.Dict.t<string>, body: option<string>}

@val
external fetch: (string, options) => Js.Promise.t<Response.t> = "fetch"

let baseUrl = `http://localhost:12346`

let fetchDimension = (~componentId: string): Js.Promise.t<Js.Json.t> => {
  let url = `${baseUrl}/dimensions/${componentId}`

  fetch(
    url,
    {
      method: "GET",
      headers: Js.Dict.empty(),
      body: None,
    },
  ) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )
}

let saveDimension = (
  ~componentId: string,
  ~dimensionName: string,
  ~value: string,
  ~metric: string,
): Js.Promise.t<Js.Json.t> => {
  let url = `${baseUrl}/dimensions/${componentId}`
  let body =
    Js.Dict.fromArray([
      ("value", Js.Json.string(value)),
      ("dimensionName", Js.Json.string(dimensionName)),
      ("metric", Js.Json.string(metric)),
    ])->Js.Json.object_

  fetch(
    url,
    {
      method: "POST",
      headers: Js.Dict.fromArray([("Content-Type", "application/json")]),
      body: Some(Js.Json.stringify(body)),
    },
  ) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )
}
