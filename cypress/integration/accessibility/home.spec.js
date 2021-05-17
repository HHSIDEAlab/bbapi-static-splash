describe("A11y", () => {
  it("home page is accessible", () => {
    cy.visit("http://127.0.0.1:4000/");
    cy.injectAxe();
    cy.checkA11y();
  });
});
