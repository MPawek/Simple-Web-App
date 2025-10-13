const axios = require("axios");
const expect = require("chai").expect;
const dockerBridgeIP = "172.17.0.1";

describe("Tests to the \"/\" endpoint", () => {
    it("should return a 200 status code", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.status).to.equal(200);
    });

    it("should return a JSON object with a Message", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data).to.haveOwnProperty("message");
    });

    it("should return a JSON object with a Timestamp", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data).to.haveOwnProperty("timestamp");
    });

    it("should return a Message saying \"My name is ...\"", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data.message).to.contain("My name is");
    });

    it("should return a UNIX style timestamp (numerical values only)", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data.timestamp).to.be.a("number");
    });
    it("should return a timestamp within a few seconds of now", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        const now = Date.now();
        expect(res.data.timestamp).to.be.within(now - 5000, now);
    });
    it("should return a minified JSON object.", async () => {
        // NOTE: axios parses the JSON when it fetches it, changing the object; we've got to make sure it doesn't do that first with second parameter
        const res = await axios(`http://${dockerBridgeIP}:80/`, {transformResponse: r => r});

        // Seems to be Chai assertion library based on use of 'expect' and code at top
        // Format of line: expect == the assertion; () => is used to delay the execution of JSON.parse function until expect runs, otherwise if it doesn't work it can crash the test
        // JSON.parse == function to parse a JSON object, checks to make sure it's the correct object type
        // res.data == what the returned object is named for these tests
        // .not.to.throw() == If no error is thrown, returns true and passes the test
        expect(() => JSON.parse(res.data)).not.to.throw();

        // NOTE: If we're specifically testing for a minified JSON object, we have to make sure there aren't any whitespaces, newlines, indentations, linebreaks, etc.
        // Check to make sure the JSON object has no readability formatting 
        // .not.to.match(/***/) checks the pattern defined in the slashes (where the stars would be) to see if it's present in res.data
        // \n == newline ; \r == carriage return (another newline) ; \t == tab ; \s == any whitespace character ; {2,} == repeated twice in a row (To avoid useless double spacing)
        // Note that everything inside the parenthesis is matches literally, so any spaces included are considered to be part of the match
        expect(res.data).not.to.match(/(\n|\r|\t|\s{2,})/);
    });
});
