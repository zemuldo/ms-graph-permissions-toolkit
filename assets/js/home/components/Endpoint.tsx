import { Link } from "@mui/material";
import React from "react";

const getDocUrl = (scheme, doc) => {
    const name = doc.split("/").slice(-1)[0].split(".")[0]
    if (scheme === 'beta') return `https://docs.microsoft.com/en-us/graph/api/${name}?view=graph-rest-beta.0&tabs=http`;
     return `https://docs.microsoft.com/en-us/graph/api/${name}?view=graph-rest-beta.0&tabs=http`
}

const Endpoint = ({ endpoint, doc, scheme }) => {
    const docUrl = getDocUrl(scheme, doc)
    console.log(docUrl);
    return (
      <span style={{ fontSize: "24px" }}>
        <Link href={docUrl} underline="none" target="_blank" rel="noopener">
          {endpoint}
        </Link>
      </span>
    );
};

export default Endpoint;
