import { Link } from "@mui/material";
import React from "react";

const getDocUrl = (scheme, doc) => {
    const name = doc.split("/").slice(-1)[0].split(".")[0]
    if (scheme === 'beta') return `https://docs.microsoft.com/en-us/graph/api/${name}?view=graph-rest-beta.0&tabs=http`;
     return `https://docs.microsoft.com/en-us/graph/api/${name}?view=graph-rest-beta.0&tabs=http`
}

const getHttpMethod = (text) => {
  if(text.includes("-update")) return "PATCH"
  if(text.includes("-post")) return "POST"
  if(text.includes("-create")) return "POST"
  if(text.includes("-delete")) return "DELETE"
  if(text.includes("-get")) return "GET"
  if(text.includes("-list")) return "GET"
  return "GET"
}

const getResourceInDoc = (doc) => {
  return doc.split("/").slice(-1)[0].split("-")[0]
}
const Endpoint = ({ endpoint, doc, scheme }) => {
  const docUrl = getDocUrl(scheme, doc)
  let _endpoint = endpoint;
  if (endpoint.includes(">>")) {
    const parts = endpoint.split(">>");
    console.log(parts);
    _endpoint = getHttpMethod(doc) + " " + parts[0] + " " + getResourceInDoc(doc);
  }
    return (
      <span style={{ fontSize: "24px" }}>
        <Link href={docUrl} underline="none" target="_blank" rel="noopener">
          {_endpoint}
        </Link>
      </span>
    );
};

export default Endpoint;
