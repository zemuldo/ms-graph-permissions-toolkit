import * as React from "react";
import Button from "@mui/material/Button";
import CssBaseline from "@mui/material/CssBaseline";
import Box from "@mui/material/Box";
import Container from "@mui/material/Container";
import { createTheme, ThemeProvider } from "@mui/material/styles";
import Header from "./components/AppBar";
import {
  Checkbox,
  FormControl,
  FormControlLabel,
  FormGroup,
  Input,
  InputAdornment,
} from "@mui/material";
import Search from "@mui/icons-material/Search";
import Footer from "./components/Footer";
import axios from "axios";
import Endpoint from "./components/Endpoint";

interface Permission {
  doc: string;
  scheme: string;
  endpoint: string;
  permission_type: string;
  privilege_weight: string;
}
interface SelectedPermissionTypes {
  delegatedWS: boolean;
  delegatedMSA: boolean;
  application: boolean;
}

const theme = createTheme();

export default function Album() {
  const [data, setData] = React.useState([]);
  const [search, setSearch] = React.useState("User.ReadWrite.All");
  const [selectedTypes, setSelectedTypes] = React.useState(
    {} as SelectedPermissionTypes
  );

  const fetchData = (_search, _selectedTypes) => {
    if (!_search) return
      const types: Array<string> = [];
    if (_selectedTypes.delegatedWS) {
      types.push("Delegated (work or school account)");
    }
    if (_selectedTypes.delegatedMSA) {
      types.push("Delegated (personal Microsoft account)");
    }
    if (_selectedTypes.application) {
      types.push("Application");
    }
    axios
      .get(`/api/permissions/search?query=${_search}&types=${types}`)
      .then(({ data }) => setData(data))
      .catch((_) => _);
  };

  const keyPress = (e) => {
    if (e.keyCode == 13) {
      fetchData(e.target.value, selectedTypes);
    }
  };

  const onSelectDelegatedWS = (e) => {
    setSelectedTypes({ ...selectedTypes, delegatedWS: e.target.checked });
    fetchData(search, { ...selectedTypes, delegatedWS: e.target.checked });
  };
  const onSelectDelegatedMSA = (e) => {
    setSelectedTypes({ ...selectedTypes, delegatedMSA: e.target.checked });
    fetchData(search, { ...selectedTypes, delegatedMSA: e.target.checked });
  };
  const onSelectApplication = (e) => {
    setSelectedTypes({ ...selectedTypes, application: e.target.checked });
    fetchData(search, { ...selectedTypes, application: e.target.checked });
  };
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Header />
      <main style={{ marginTop: "2vh" }}>
        <Container maxWidth="md">
          <Input
            value={search}
            fullWidth
            onKeyDown={keyPress}
            onChange={(e) => setSearch(e.target.value)}
            type="search"
            id="input-with-icon-adornment"
            startAdornment={
              <InputAdornment position="start">
                <Search />
              </InputAdornment>
            }
          />
          <div style={{ display: "flex", marginTop: 3 }}>
            <div style={{ flex: 2, textAlign: "left" }}>
              <FormControlLabel
                control={
                  <Checkbox
                    onChange={onSelectDelegatedWS}
                    checked={!!selectedTypes["delegatedWS"]}
                  />
                }
                label="Delegated (work or school)"
              />
            </div>
            <div style={{ flex: 2, textAlign: "center" }}>
              <FormControlLabel
                control={
                  <Checkbox
                    onChange={onSelectDelegatedMSA}
                    checked={!!selectedTypes["delegatedMSA"]}
                  />
                }
                label="Delegated (Personal Microsoft)"
              />
            </div>
            <div style={{ flex: 1, textAlign: "right" }}>
              <FormControlLabel
                control={
                  <Checkbox
                    onChange={onSelectApplication}
                    checked={!!selectedTypes["application"]}
                  />
                }
                label="Application"
              />
            </div>
          </div>
          <div style={{ marginTop: 10, minHeight: "75vh" }}>
            {data.map((p: Permission) => (
              <div
                key={`${p.doc}-${p.endpoint}-${p.permission_type}-${p.privilege_weight}`}
                style={{ marginTop: 2 }}
              >
                <div>
                  <Endpoint endpoint={p.endpoint} doc={p.doc} scheme={p.scheme} />
                  <br />
                  <span>{p.doc}</span>
                  <br />
                  <span>{p.resource}</span>
                  <br />
                  <span style={{ display: "flex" }}>
                    <span style={{ flex: 4 }}>
                      Permission Type:{" "}
                      <Button size="small">{p.permission_type}</Button>
                    </span>
                    <span style={{ flex: 1, textAlign: "right" }}>
                      Privilege:{" "}
                      <Button size="small">{p.privilege_weight}</Button>
                    </span>
                  </span>
                </div>
                <hr />
              </div>
            ))}
          </div>
        </Container>
      </main>
      <footer>
        <Footer />
      </footer>
    </ThemeProvider>
  );
}
