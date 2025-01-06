"use client";
import { ConnectButton } from "@rainbow-me/rainbowkit";

const Header = () => {
  return (
    <header className="header">
      <h1 className="title">Human Pass</h1>
      <nav>
        <a style={{ paddingRight: "15px" }} href="#section2">
          Dashboard
        </a>
      </nav>
      <ConnectButton />
    </header>
  );
};

export default Header;
