import { Link } from "react-router-dom";
import EmptyState from "../components/EmptyState";

export default function NotFoundPage() {
  return (
    <div className="page">
      <EmptyState
        icon="🍿"
        title="This page rolled the credits"
        hint="The link may be out of date, or the address may have a typo in it."
        action={
          <Link className="btn btn--primary btn--lg" to="/">
            Back to Discover
          </Link>
        }
      />
    </div>
  );
}
